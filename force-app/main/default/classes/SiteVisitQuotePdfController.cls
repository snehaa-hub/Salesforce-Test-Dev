public class SiteVisitQuotePdfController {
    public List<Unit_Bundle__c> unitBundles{get;set;}
    public Opportunity opp{get;set;}
    public List<Unit__c> shortListUnits{get;set;}
    public List<String> internalImageUrlList{get;set;}
    public List<String> externalImageUrlList{get;set;}
    
    public SiteVisitQuotePdfController(){
        String unitBundleId = ApexPages.CurrentPage().getparameters().get('id');
        Set<Id> shortListIdSet = New Set<Id>();                                                                          
        Set<Id> unitIdSet = New Set<Id>();
        externalImageUrlList = New List<String>();
        internalImageUrlList = New List<String>();
        SObjectAccessDecision decisionbuilderopediaUnitBundle = Security.stripInaccessible(AccessType.READABLE,
                                                                                           [SELECT Id, Name, Linked_Unit__c
                                                                                            FROM Unit_Bundle__c
                                                                                            WHERE Id =: unitBundleId]);
        if(!(decisionbuilderopediaUnitBundle.getRecords()).isEmpty() ){
            unitBundles = (List<Unit_Bundle__c>) decisionbuilderopediaUnitBundle.getRecords();
            for(Unit_Bundle__c unitBundle:unitBundles){
                List<String> shortlistedUnitIds = (List<String>) JSON.deserialize(unitBundle.Linked_Unit__c, List<String>.class);
                for(String shortListId: shortlistedUnitIds){
                    shortListIdSet.add(shortListId);
                }
            }
            system.debug('shortListIdSet'+shortListIdSet);
            
            SObjectAccessDecision decisionbuilderopediaUnit = Security.stripInaccessible(AccessType.READABLE,
                                                                                         [SELECT Id, Name,
                                                                                          Building_Type__c,
                                                                                          Ceiling_Side_Height__c,
                                                                                          Ceiling_Side_Height_UOM__c,
                                                                                          Ceiling_Center_Height__c,
                                                                                          Ceiling_Center_Height_UOM__c,
                                                                                          Flooring_Strength_per_MT__c,
                                                                                          Floor_ht_from_ground_level__c,
                                                                                          Floor_ht_from_ground_level_UOM__c,
                                                                                          No_of_shutters__c,
                                                                                          Fire_Noc_available__c,
                                                                                          Fire_Safety__c,
                                                                                          Power_available__c,
                                                                                          Rent_per_uom_Price_per_uom__c,
                                                                                          Total_Rent_Total_Price__c,
                                                                                          SIDCO_SIPCOT_CAM_or_Addl_Charges__c,
                                                                                          SIDCO_SIPCOT_CAM_or_Addl_Charges_UOM__c,
                                                                                          City__c,
                                                                                          Canopy_available__c,
                                                                                          Dock_Leveller__c,
                                                                                          Advance_Security_Deposit__c,
                                                                                          EoT_Crane_Provision__c,
                                                                                          Office_space_available__c,
                                                                                          Escalation__c,
                                                                                          (SELECT Id, Name 
                                                                                                           FROM Shortlisted_Units__r)
                                                                                          FROM Unit__c
                                                                                          WHERE Id IN  (
                                                                                              SELECT Unit__c 
                                                                                              FROM Shortlisted_Unit__c 
                                                                                              WHERE Id IN :shortListIdSet
                                                                                          )]);
            
            
            if(!(decisionbuilderopediaUnit.getRecords()).isEmpty() ){
                shortListUnits = (List<Unit__c>) decisionbuilderopediaUnit.getRecords();
                for(Unit__c unit:shortListUnits){
                    system.debug('unit'+unit);
                    unitIdSet.add(unit.id);
                }
            }
            system.debug('unitIdSet'+unitIdSet);
            if(!unitIdSet.isEmpty())
            {
                List<contentVersion> contentVersionList =[SELECT ID,ContentDocumentId,FirstPublishLocationId,
                                                          title
                                                          FROM contentVersion
                                                          WHERE FirstPublishLocationId  IN:unitIdSet
                                                          AND Document_Type__c = 'Internal Images'];
                List<contentVersion> contentVersionExternalList =[SELECT ID,ContentDocumentId,FirstPublishLocationId,
                                                                  title
                                                                  FROM contentVersion
                                                                  WHERE FirstPublishLocationId  IN:unitIdSet
                                                                  AND Document_Type__c = 'External Images'];
                system.debug('contentVersionList'+contentVersionList);
                system.debug('contentVersionExternalList--> '+contentVersionExternalList);
                Map<ID,List<String>> mapOfContentVersion = New  Map<ID,List<String>>(); 
                Map<ID,List<String>> mapOfExternalContentVersion = New  Map<ID,List<String>>(); 
                for(contentVersion thisCV:contentVersionList)
                {
                    String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.id;
                    system.debug('imageURL--> '+imageURL);
                    internalImageUrlList.add(imageURL);
                    system.debug('internalImageUrlList--> '+internalImageUrlList);
                    
                    /*if(mapOfContentVersion.containsKey(thisCV.FirstPublishLocationId))
                    {    List <String>  internalList = New List <String> ();
                     internalList =mapOfContentVersion.get(thisCV.FirstPublishLocationId);
                     String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.id;
                     internalList.add(imageURL);
                     mapOfContentVersion.put(thisCV.FirstPublishLocationId,internalList);
                    }
                    else
                    {
                        String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.id;
                        mapOfContentVersion.put(thisCV.FirstPublishLocationId, New List <String> {imageURL});
                    }*/
                }
                for(contentVersion thisCV2:contentVersionExternalList)
                {
                    String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV2.id;
                    system.debug('imageURL--> '+imageURL);
                    externalImageUrlList.add(imageURL);
                    system.debug('externalImageUrlList--> '+externalImageUrlList);
                    
                    /*if(mapOfExternalContentVersion.containsKey(thisCV2.FirstPublishLocationId))
                    {    List <String>  internalList = New List <String> ();
                     internalList =mapOfExternalContentVersion.get(thisCV2.FirstPublishLocationId);
                     String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV2.id;
                     internalList.add(imageURL);
                     mapOfExternalContentVersion.put(thisCV2.FirstPublishLocationId,internalList);
                    }
                    else
                    {
                        String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV2.id;
                        mapOfExternalContentVersion.put(thisCV2.FirstPublishLocationId, New List <String> {imageURL});
                    }*/
                }
                
                system.debug('mapOfContentVersion'+mapOfContentVersion);
                system.debug('mapOfExternalContentVersion--> '+mapOfExternalContentVersion);
            }
        }
    }
}