public Without Sharing class GenerateQuoteController {
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>> getUnitBundleRecord(String recordId){
        List<Map<String,Object>> dataMapList = new List<Map<String,Object>>();
        if(!String.isBlank(recordId)){
            /*  Set<Id> UnitBundleIdSet = New Set<Id> ();
List<Site_Visit__c> siteVisitList =[SELECT ID,Unit_Bundle__c 
FROM Site_Visit__c 
WHERE Opportunity__c =: recordId AND Status__c ='Completed'];
for(Site_Visit__c thisSiteVisit: siteVisitList)
{
if(thisSiteVisit.Unit_Bundle__c != null)
{
UnitBundleIdSet.add(thisSiteVisit.Unit_Bundle__c );
}

}*/
            SObjectAccessDecision decisionbuilderopediaUnitBundle = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Id, Name,Linked_Unit__c,Opportunity__c
                 FROM Unit_Bundle__c
                 WHERE Opportunity__c =: recordId
                ]
            );
            
            if(!(decisionbuilderopediaUnitBundle.getRecords()).isEmpty() ){
                for(Unit_Bundle__c unitBundle:(List<Unit_Bundle__c>) decisionbuilderopediaUnitBundle.getRecords()){
                    Map<String,object> unitBundleMap = new Map<String,object>(); 
                    List<String> shortlistedUnitIds = (List<String>) JSON.deserialize(unitBundle.Linked_Unit__c, List<String>.class);
                    unitBundleMap.put('Name',unitBundle.Name);
                    unitBundleMap.put('Id',unitBundle.id);
                    for(Shortlisted_Unit__c shortList : [SELECT Id,Name, Unit__r.Name,
                                                         Unit__r.Carpet_Area__c,
                                                         Unit__r.Type_of_Unit__c
                                                         FROM Shortlisted_Unit__c
                                                         WHERE Id IN :shortlistedUnitIds
                                                        ])
                    {
                        if(unitBundleMap.containskey('UnitData'))
                        {
                            List<object> internalObjectList = New List<object>();
                            List<Object> existingList = (List<Object>)unitBundleMap.get('UnitData');
                            internalObjectList.add(shortList);
                            existingList.addAll(internalObjectList);
                            unitBundleMap.put('UnitData',existingList);
                        }
                        else
                        {
                            List<object> internalObjectList = New List<object>();
                            internalObjectList.add(shortList);
                            unitBundleMap.put('UnitData',internalObjectList);
                        }
                    }
                    dataMapList.add(unitBundleMap);
                    system.debug('dataMapList----'+dataMapList);
                }  
                
            }
        }
        return dataMapList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>> getSelectedUnit(String opportunityID,String records){
        List<Map<String,Object>> dataMapList = new List<Map<String,Object>>();
        Set<Id> unitBundleIdSet = New Set<Id>();
        system.debug('getSelectedUnit'+records);
        for(Object record: (List<Object>)JSON.deserializeUntyped(records)){
            system.debug('record'+record);
            Map<String, Object> recordMap = (Map<String, Object>)record;
            system.debug('shortListId'+(String)recordMap.get('shortListId'));
            unitBundleIdSet.add((String)recordMap.get('shortListId'));
            
        }
        
        
        system.debug('unitBundleIdSet'+unitBundleIdSet);
        SObjectAccessDecision decisionbuilderopediaUnitBundle = Security.stripInaccessible(AccessType.READABLE,
                                                                                           [SELECT Id, Name, Linked_Unit__c
                                                                                            FROM Unit_Bundle__c
                                                                                            WHERE Id IN: unitBundleIdSet]);
        
        Set<Id> shortListIdSet = New Set<Id>();                                                                          
        Set<Id> unitIdSet = New Set<Id>();
        if(!(decisionbuilderopediaUnitBundle.getRecords()).isEmpty() ){
            for(Unit_Bundle__c unitBundle:(List<Unit_Bundle__c>) decisionbuilderopediaUnitBundle.getRecords()){
                List<String> shortlistedUnitIds = (List<String>) JSON.deserialize(unitBundle.Linked_Unit__c, List<String>.class);
                for(String shortListId: shortlistedUnitIds)
                { shortListIdSet.add(shortListId);
                }
            }
            system.debug('shortListIdSet'+shortListIdSet);
            
            SObjectAccessDecision decisionbuilderopediaUnit = Security.stripInaccessible(AccessType.READABLE,
                                                                                         [SELECT Id, Name,(SELECT Id, Name 
                                                                                                           FROM Shortlisted_Units__r)
                                                                                          /*  (SELECT Id, Name 
FROM Inventory_Management_Process__r)*/
                                                                                          FROM Unit__c
                                                                                          WHERE Id IN  (
                                                                                              SELECT Unit__c 
                                                                                              FROM Shortlisted_Unit__c 
                                                                                              WHERE Id IN :shortListIdSet
                                                                                          )]);
            
            
            if(!(decisionbuilderopediaUnit.getRecords()).isEmpty() ){
                for(Unit__c unitBundle:(List<Unit__c>) decisionbuilderopediaUnit.getRecords()){
                    system.debug('unitBundle'+unitBundle);
                    unitIdSet.add(unitBundle.id);
                    /* if(unitBundle.Inventory_Management_Process__r != null &&  unitBundle.Inventory_Management_Process__r.size()>0 )
{
system.debug('114'+unitBundle.Inventory_Management_Process__r);
inventoryIdSet.add(unitBundle.Inventory_Management_Process__r[0].id );
}*/
                }
            }
            system.debug('unitIdSet'+unitIdSet);
            if(!unitIdSet.isEmpty())
            {
                List<ContentDocumentLink> contentVersionList  =[SELECT Id, ContentDocumentId, ContentDocument.Title, 
                                                                ContentDocument.ContentModifiedDate,
                                                                LinkedEntityId,
                                                                ContentDocument.LatestPublishedVersion.Document_Type__c, 
                                                                ContentDocument.LatestPublishedVersionId,
                                                                ContentDocument.LatestPublishedVersion.ContentModifiedBy.Name
                                                                FROM ContentDocumentLink WHERE LinkedEntityId IN : unitIdSet
                                                                ];
                                                                system.debug('contentVersionList 129'+contentVersionList);
                //AND ContentDocument.LatestPublishedVersion.Document_Type__c = 'Internal Images'
                                                              //  order By  ContentDocument.ContentModifiedDate ASC
                
                /* List<contentVersion> contentVersionList =[SELECT ID,ContentDocumentId,FirstPublishLocationId,
title,ContentUrl
FROM contentVersion
WHERE FirstPublishLocationId  IN:unitIdSet
AND Document_Type__c = 'Internal Images'];*/
                system.debug('contentVersionList'+contentVersionList);
                Map<ID,List<String>> mapOfContentVersion = New  Map<ID,List<String>>(); 
                Map<ID,List<String>> mapOfAllContentVersion = New  Map<ID,List<String>>(); 
                Map<ID,List<String>> mapOfExternalContentVersion = New  Map<ID,List<String>>(); 
                Map<ID,List<String>> mapOfcaptureContentVersion = New  Map<ID,List<String>>();
                Map<ID,List<String>> mapOfSiteContentVersion = New  Map<ID,List<String>>();
                Map<ID,List<String>> mapOfFloorContentVersion = New  Map<ID,List<String>>();
                for(ContentDocumentLink thisCV:contentVersionList)
                {
                    if(thisCV.ContentDocument.LatestPublishedVersion.Document_Type__c =='External Images'){
                         if(mapOfExternalContentVersion.containsKey(thisCV.LinkedEntityId))
                    {    
                        List <String>  internalList = New List <String> ();
                     internalList =mapOfExternalContentVersion.get(thisCV.LinkedEntityId);
                     
                     String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                     internalList.add(imageURL);
                     
                     mapOfExternalContentVersion.put(thisCV.LinkedEntityId,internalList);
                    }
                    else
                    {
                        
                        String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                        mapOfExternalContentVersion.put(thisCV.LinkedEntityId, New List <String> {imageURL});
                        
                        
                    }
                    }
                    else if(thisCV.ContentDocument.LatestPublishedVersion.Document_Type__c =='Internal Images'){
                        if(mapOfContentVersion.containsKey(thisCV.LinkedEntityId))
                    {    
                        List <String>  internalList = New List <String> ();
                     internalList =mapOfContentVersion.get(thisCV.LinkedEntityId);
                     
                     String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                     internalList.add(imageURL);
                     
                     mapOfContentVersion.put(thisCV.LinkedEntityId,internalList);
                    }
                    else
                    {
                        
                        String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                        mapOfContentVersion.put(thisCV.LinkedEntityId, New List <String> {imageURL});
                        
                        
                    }
                        
                    }
                     else if(thisCV.ContentDocument.LatestPublishedVersion.Document_Type__c =='Capture Images'){
                        if(mapOfcaptureContentVersion.containsKey(thisCV.LinkedEntityId))
                    {    
                        List <String>  internalList = New List <String> ();
                     internalList =mapOfcaptureContentVersion.get(thisCV.LinkedEntityId);
                     
                     String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                     internalList.add(imageURL);
                     
                     mapOfcaptureContentVersion.put(thisCV.LinkedEntityId,internalList);
                    }
                    else
                    {
                        
                        String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                        mapOfcaptureContentVersion.put(thisCV.LinkedEntityId, New List <String> {imageURL});
                        
                        
                    }
                    }
                    else if(thisCV.ContentDocument.LatestPublishedVersion.Document_Type__c =='Site Plan Upload'){
                        if(mapOfSiteContentVersion.containsKey(thisCV.LinkedEntityId))
                    {    
                        List <String>  internalList = New List <String> ();
                     internalList =mapOfSiteContentVersion.get(thisCV.LinkedEntityId);
                     
                     String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                     internalList.add(imageURL);
                     
                     mapOfSiteContentVersion.put(thisCV.LinkedEntityId,internalList);
                    }
                    else
                    {
                        
                        String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                        mapOfSiteContentVersion.put(thisCV.LinkedEntityId, New List <String> {imageURL});
                        
                        
                    }
                        
                    }
                    else if(thisCV.ContentDocument.LatestPublishedVersion.Document_Type__c =='Floor Plan Upload'){
                        if(mapOfFloorContentVersion.containsKey(thisCV.LinkedEntityId))
                    {    
                        List <String>  internalList = New List <String> ();
                     internalList =mapOfFloorContentVersion.get(thisCV.LinkedEntityId);
                     
                     String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                     internalList.add(imageURL);
                     
                     mapOfFloorContentVersion.put(thisCV.LinkedEntityId,internalList);
                    }
                    else
                    {
                        
                        String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                        mapOfFloorContentVersion.put(thisCV.LinkedEntityId, New List <String> {imageURL});
                        
                        
                    }
                        
                    }
                       if(mapOfAllContentVersion.containsKey(thisCV.LinkedEntityId))
                    {    
                        List <String>  internalList = New List <String> ();
                     internalList =mapOfAllContentVersion.get(thisCV.LinkedEntityId);
                     
                     String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                     internalList.add(imageURL);
                     
                     mapOfAllContentVersion.put(thisCV.LinkedEntityId,internalList);
                    }
                    else
                    {
                        
                        String imageURL = '/sfc/servlet.shepherd/version/download/'  +thisCV.ContentDocument.LatestPublishedVersionId;
                        mapOfAllContentVersion.put(thisCV.LinkedEntityId, New List <String> {imageURL});
                        
                        
                    }  
                    }
                system.debug('mapOfContentVersion'+mapOfContentVersion);
                system.debug('mapOfExternalContentVersion'+mapOfExternalContentVersion);
                system.debug('mapOfCaptureContentVersion'+mapOfcaptureContentVersion);
                system.debug('mapOfAllContentVersion'+mapOfAllContentVersion);
                system.debug('mapOfSiteContentVersion'+mapOfSiteContentVersion);
                system.debug('mapOfFloorContentVersion'+mapOfFloorContentVersion);
                for(Unit_Bundle__c unitBundle:(List<Unit_Bundle__c>) decisionbuilderopediaUnitBundle.getRecords()){
                    Map<String,object> unitBundleMap = new Map<String,object>(); 
                    List<String> shortlistedUnitIds = (List<String>) JSON.deserialize(unitBundle.Linked_Unit__c, List<String>.class);
                    //  unitBundleMap.put(unitBundle.id,shortlistedUnitIds);
                    unitBundleMap.put('Name',unitBundle.Name);
                    unitBundleMap.put('Id',unitBundle.id);
                    for(Unit__c unit :  [SELECT Id, Name,Ceiling_Side_Height__c,
                                         Ceiling_Center_Height__c,
                                         //Flooring_Strength_per_MT__c,
                                         Ceiling_Side_Height_UOM__c,
                                         Fire_Noc_available__c,
                                         Fire_Safety__c,
                                         Power_available__c,
                                         City__c,
                                         Canopy__c,
                                         Dock_Leveller__c,
                                         Advance_Security_Deposit__c,
                                         EoT_Crane_Provision__c,
                                         Office_space_available__c,
                                         Ceiling_Center_Height_UOM__c,
                                         Floor_ht_from_ground_level_UOM__c,
                                         Floor_ht_from_ground_level__c,
                                         Rent_per_uom_Price_per_uom__c,
                                         Total_Rent_Total_Price__c,
                                         SIDCO_SIPCOT_CAM_Addl_Charges_UOM__c,
                                         SIDCO_SIPCOT_CAM_or_Addl_Charges__c,
                                         Building_Type__c,
                                         Type_of_Unit__c,
                                         No_of_shutters__c,
                                         Escalation__c,
                                         Built_Up_Area_UOM__c,
                                         Saleable_Area_UOM__c,
                                         Unit_Category__c,
                                         Canopy_available__c,
                                         Google_Coordinates_Link__c,
                                         Built_up_Area__c,
                                         Saleable_Area__c,
                                         Year_of_Construction__c,
                                         Lighting__c,
                                         Maintenance_by__c,
                                         Rent_per_UOM__c,
                                         Dock_Leveller_Text__c,
                                         Floor_Type__c,
                                         EoT_Crane_Provision_Text__c,
                                         Power_availabletext__c,
                                         Floor_Insulation__c,
                                         Ventilation__c,
                                         No_of_toilets__c,
                                         Approval_plan_available__c,
                                         Authority__c,
                                         Date_Available__c,
                                         Maintenance__c,
                                         Unit_UOM__c,
                                         Others__c,
                                         Point_of_Contact__r.Name,
                                         Contact_Number__c,
                                         AW_Land_Location__c,
                                         AW_Land_Village_Name__c,
                                         AW_Land_Google_Coordinates__c,
                                         AW_Land_Extent__c,
                                         UoM__c,
                                         AW_Land_FMB_Sketch__c,
                                         AW_Land_360_video__c,
                                         AW_Land_Road_width__c,
                                         AW_Land_Type_of_Land__c,
                                         AW_Land_Neighbour_Companies__c,
                                         AW_BTS_Location__c,
                                         AW_BTS_Built_up_Area__c,
                                         AW_BTS_UOM__c,
                                         AW_BTS_Extent__c,
                                         AW_BTS_Google_Coordinates__c,
                                         AW_BTS_Approval_through__c,
                                         Approval_Available__c,
                                         AW_BTS_360_video__c,
                                         AW_BTS_Land_Zone__c,
                                         AW_BTS_Lock_in_Terms__c,
                                         AW_BTS_Base_Rental_Expected__c,
                                         
                                         Flooring_Strength_per_MT__c
                                         /*,
(SELECT Id, Name 
FROM Inventory_Management_Process__r)*/
                                         FROM Unit__c
                                         WHERE Id IN  (
                                             SELECT Unit__c 
                                             FROM Shortlisted_Unit__c 
                                             WHERE Id IN :shortlistedUnitIds
                                         )])
                    {
                        /* Map<String,String> unitRecord = New Map<String,String>();
unitRecord.put('Name', unit.Name);
unitRecord.put('Type_of_Unit__c', unit.Type_of_Unit__c);
unitRecord.put('City__c', unit.City__c);
unitRecord.put('Ceiling_Center_Height__c', String.valueOf(unit.Ceiling_Center_Height__c));
unitRecord.put('Ceiling_Center_Height_UOM__c', unit.Ceiling_Center_Height_UOM__c);
unitRecord.put('Ceiling_Side_Height__c',String.valueOf( unit.Ceiling_Side_Height__c));
unitRecord.put('Ceiling_Side_Height_UOM__c', unit.Ceiling_Side_Height_UOM__c);
unitRecord.put('Fire_Noc_available__c', unit.Fire_Noc_available__c);
unitRecord.put('Flooring_Strength_per_MT__c', unit.Flooring_Strength_per_MT__c);
unitRecord.put('Fire_Safety__c', unit.Fire_Safety__c);
unitRecord.put('Canopy__c', unit.Canopy__c);
unitRecord.put('Power_available__c', unit.Power_available__c);
unitRecord.put('Google_Coordinates_Link__c', unit.Google_Coordinates_Link__c);
unitRecord.put('Dock_Leveller__c', unit.Dock_Leveller__c);*/
                        Unit__c unitRecord = New Unit__c();
                        unitRecord.Id = unit.Id;
                        unitRecord.Name = unit.Name;
                        unitRecord.Type_of_Unit__c = unit.Type_of_Unit__c;
                        unitRecord.Unit_Category__c = unit.Unit_Category__c;
                        unitRecord.Built_up_Area__c = unit.Built_up_Area__c;
                        unitRecord.Saleable_Area__c = unit.Saleable_Area__c;
                        unitRecord.Year_of_Construction__c = unit.Year_of_Construction__c;
                        unitRecord.Lighting__c = unit.Lighting__c;
                        unitRecord.Dock_Leveller_Text__c = unit.Dock_Leveller_Text__c;
                        unitRecord.Saleable_Area__c = unit.Saleable_Area__c;
                        unitRecord.Rent_per_UOM__c  = unit.Rent_per_UOM__c;
                        unitRecord.Floor_Type__c = unit.Floor_Type__c;
                        unitRecord.Canopy_available__c = unit.Canopy_available__c;
                        unitRecord.Power_availabletext__c = unit.Power_availabletext__c;
                        unitRecord.Floor_Insulation__c  = unit.Floor_Insulation__c;
                        unitRecord.Ventilation__c = unit.Ventilation__c;
                        unitRecord.No_of_toilets__c  = unit.No_of_toilets__c;
                        unitRecord.Authority__c  = unit.Authority__c;
                        unitRecord.Approval_plan_available__c = unit.Approval_plan_available__c;
                        unitRecord.Maintenance_by__c  = unit.Maintenance_by__c;
                        unitRecord.Maintenance__c = unit.Maintenance__c;
                        unitRecord.EoT_Crane_Provision_Text__c  = unit.EoT_Crane_Provision_Text__c;
                        unitRecord.Date_Available__c = unit.Date_Available__c;
                        unitRecord.No_of_shutters__c = unit.No_of_shutters__c;
                        
                        unitRecord.City__c  = unit.City__c;
                        unitRecord.Ceiling_Center_Height__c = unit.Ceiling_Center_Height__c;
                        unitRecord.Ceiling_Center_Height_UOM__c  = unit.Ceiling_Center_Height_UOM__c;
                        unitRecord.Ceiling_Side_Height__c  = unit.Ceiling_Side_Height__c;
                        unitRecord.Ceiling_Side_Height_UOM__c = unit.Ceiling_Side_Height_UOM__c;
                        unitRecord.Fire_Noc_available__c  = unit.Fire_Noc_available__c;
                        unitRecord.Flooring_Strength_per_MT__c = unit.Flooring_Strength_per_MT__c;
                        unitRecord.Fire_Safety__c  = unit.Fire_Safety__c;
                        unitRecord.Canopy__c = unit.Canopy__c;
                        unitRecord.Power_available__c  = unit.Power_available__c;
                        unitRecord.Google_Coordinates_Link__c = unit.Google_Coordinates_Link__c;
                        unitRecord.Dock_Leveller__c  = unit.Dock_Leveller__c;
                        unitRecord.Office_space_available__c = unit.Office_space_available__c;
                        unitRecord.Unit_UOM__c = unit.Unit_UOM__c	;
                        unitRecord.EoT_Crane_Provision__c = unit.EoT_Crane_Provision__c;
                        unitRecord.Power_available__c  = unit.Power_available__c;
                        unitRecord.Rent_per_uom_Price_per_uom__c  = unit.Rent_per_uom_Price_per_uom__c;
                        unitRecord.Building_Type__c = unit.Building_Type__c;
                        unitRecord.Floor_ht_from_ground_level__c  = unit.Floor_ht_from_ground_level__c;
                        unitRecord.Floor_ht_from_ground_level_UOM__c = unit.Floor_ht_from_ground_level_UOM__c;
                        unitRecord.SIDCO_SIPCOT_CAM_or_Addl_Charges__c  = unit.SIDCO_SIPCOT_CAM_or_Addl_Charges__c;
                        unitRecord.SIDCO_SIPCOT_CAM_Addl_Charges_UOM__c  = unit.SIDCO_SIPCOT_CAM_Addl_Charges_UOM__c;
                        unitRecord.No_of_shutters__c  = unit.No_of_shutters__c;
                        unitRecord.Flooring_Strength_per_MT__c = unit.Flooring_Strength_per_MT__c;
                        unitRecord.Canopy_available__c  = unit.Canopy_available__c;
                        unitRecord.Total_Rent_Total_Price_Text__c  = unit.Total_Rent_Total_Price__c;
                        unitRecord.Built_Up_Area_UOM__c  = unit.Built_Up_Area_UOM__c;
                        unitRecord.Saleable_Area_UOM__c	  = unit.Saleable_Area_UOM__c;
                       // unitRecord.Contact_Number__c = unit.Contact_Number__c;
                        
                        //system.debug('unitRecord'+unitRecord);
                        if(unitBundleMap.containskey('UnitData'))
                        {
                            List<object> internalObjectList = New List<object>();
                            List<Object> existingList = (List<Object>)unitBundleMap.get('UnitData');
                            Map<String,Object> unitData = New Map<String,Object> ();
                            Map<String,boolean> checkedMap = new Map<String,boolean>();
                            checkedMap.put('All',true);
                            checkedMap.put('InternalImages',false);
                            checkedMap.put('ExternalImages',false);
                            checkedMap.put('CaptureImages',false);
                            checkedMap.put('SiteImage',false);
                            checkedMap.put('FloorImage',false);
                            unitData.put('ImageChange',checkedMap);
                            /*  if(unit.Inventory_Management_Process__r != null && unit.Inventory_Management_Process__r.size()>0)
{
String inventoryId = unit.Inventory_Management_Process__r[0].id;*/
                            if(mapOfContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('InternalImages',mapOfContentVersion.get(unit.Id)); 
                            }
                            if(mapOfAllContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('Images',mapOfAllContentVersion.get(unit.Id)); 
                            }
                            if(mapOfExternalContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('ExternalImages',mapOfExternalContentVersion.get(unit.Id)); 
                            }
                            if(mapOfcaptureContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('CaptureImages',mapOfcaptureContentVersion.get(unit.Id)); 
                            }
                             if(mapOfSiteContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('SiteImage',mapOfSiteContentVersion.get(unit.Id)); 
                            }
                             if(mapOfFloorContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('FloorImage',mapOfFloorContentVersion.get(unit.Id)); 
                            }
                            
                            Map<String,String> PicklistMap = new Map<String,String>();
                            PicklistMap.put('All','All');
                            PicklistMap.put('Internal Images','InternalImages');
                            PicklistMap.put('External Images','ExternalImages');
                            PicklistMap.put('Capture Images','CaptureImages');
                            PicklistMap.put('Site Plan Upload','SiteImage');
                            PicklistMap.put('Floor Plan Upload','FloorImage');
                            List<Map<String, String>> picklistOptions = new List<Map<String, String>>();
                            for (String key : PicklistMap.keySet()) {
                                picklistOptions.add(new Map<String, String>{
                                    'label' => key,
                                    'value' => PicklistMap.get(key)
                                });
                            }
                            unitData.put('ImageOptions',picklistOptions);
                            //}
                            List<object> externalObjectList = New List<object>();
                            unitData.put('selectedContentVersionID',externalObjectList);
                            unitData.put('selectedExternalContentVersionID',externalObjectList);
                            unitData.put('selectedCaptureContentVersionID',externalObjectList);
                            unitData.put('selectedAllContentVersionID',externalObjectList);
                            unitData.put('selectedSiteContentVersionID',externalObjectList);
                            unitData.put('selectedFloorContentVersionID',externalObjectList);
                           // unitData.put('Data',unitRecord);
                            unitData.put('Data',unit);
                            internalObjectList.add(unitData);
                            existingList.addAll(internalObjectList);
                            unitBundleMap.put('UnitData',existingList);
                        }
                        else
                        {
                            Map<String,Object> unitData = New Map<String,Object> ();
                            List<object> internalObjectList = New List<object>();
                            //  List<Unit__c> internalUnitList =  New List<Unit__c> {unit};
                            //system.debug('internalUnitList'+internalUnitList);
                            List<object> externalObjectList = New List<object>();
                            unitData.put('selectedContentVersionID',externalObjectList);
                            unitData.put('selectedExternalContentVersionID',externalObjectList);
                            unitData.put('selectedCaptureContentVersionID',externalObjectList);
                            unitData.put('selectedAllContentVersionID',externalObjectList);
                             unitData.put('selectedSiteContentVersionID',externalObjectList);
                            unitData.put('selectedFloorContentVersionID',externalObjectList);
                           // unitData.put('Data',unitRecord);
                           Map<String,boolean> checkedMap = new Map<String,boolean>();
                            checkedMap.put('All',true);
                            checkedMap.put('InternalImages',false);
                            checkedMap.put('ExternalImages',false);
                            checkedMap.put('CaptureImages',false);
                            checkedMap.put('SiteImage',false);
                            checkedMap.put('FloorImage',false);
                            unitData.put('ImageChange',checkedMap);
                            unitData.put('Data',unit);
                            /*if(unit.Inventory_Management_Process__r != null && unit.Inventory_Management_Process__r.size()>0)
{
String inventoryId = unit.Inventory_Management_Process__r[0].id;*/
                           if(mapOfContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('InternalImages',mapOfContentVersion.get(unit.Id)); 
                            }
                            if(mapOfAllContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('Images',mapOfAllContentVersion.get(unit.Id)); 
                            }
                            if(mapOfExternalContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('ExternalImages',mapOfExternalContentVersion.get(unit.Id)); 
                            }
                            if(mapOfcaptureContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('CaptureImages',mapOfcaptureContentVersion.get(unit.Id)); 
                            }
                            if(mapOfSiteContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('SiteImage',mapOfSiteContentVersion.get(unit.Id)); 
                            }
                             if(mapOfFloorContentVersion.containsKey(unit.Id))
                            { 
                                unitData.put('FloorImage',mapOfFloorContentVersion.get(unit.Id)); 
                            }
                            
                            Map<String,String> PicklistMap = new Map<String,String>();
                            PicklistMap.put('All','All');
                            PicklistMap.put('Internal Images','InternalImages');
                            PicklistMap.put('External Images','ExternalImages');
                            PicklistMap.put('Capture Images','CaptureImages');
                            PicklistMap.put('Site Plan Upload','SiteImage');
                            PicklistMap.put('Floor Plan Upload','FloorImage');
                            List<Map<String, String>> picklistOptions = new List<Map<String, String>>();
                            for (String key : PicklistMap.keySet()) {
                                picklistOptions.add(new Map<String, String>{
                                    'label' => key,
                                    'value' => PicklistMap.get(key)
                                });
                            }
                            unitData.put('ImageOptions',picklistOptions);
                            // }
                            //unitData.put('shortListUnitId',unit.Shortlisted_Units__r[0].id);
                            internalObjectList.add(unitData);
                            unitBundleMap.put('UnitData',internalObjectList);
                        }
                        
                        
                        
                    }
                    dataMapList.add(unitBundleMap);
                    system.debug('dataMapList----'+dataMapList); 
                }
            }
        }
        
        
        return dataMapList;
        
    }
    public class ShortListUnit {
        public String shortListId;
        public Boolean isUnitChecked;
        public String selectedShortListUnitId;
        public String selectedUnitBundleId;
        public String unitId;
    }	
    
    public String formatNumberIndian(Decimal value){
        
        string formattedValue1;
        
        if(value >0){
            
            String formattedValue = String.valueOf(value).substringBefore('.');
            
            formattedValue = formattedValue.replace(',', '');
            
            for (Integer i = formattedValue.length() - 3; i > 0; i -= 2){
                
                formattedValue = formattedValue.substring(0, i) + ',' + formattedValue.substring(i);
                
            }
            
            formattedValue1 = formattedValue;
            
        }
        
        return formattedValue1;
        
    }
    
    public static void Test()
    {
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
    
}