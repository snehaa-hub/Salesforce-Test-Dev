public class GetSiteVisitInspectionChecklistMetadata {
    @AuraEnabled(cacheable = true)
    public static List<Object> execute(){
        List<Object>returnList = New List<Object>();
        List<Site_Visit_Inspection_Checklist__mdt> inspectionCheckList = [SELECT Id,Label,MasterLabel,Sequence_No__c,
                                                                                  Text_Label__c,Datatype__c
                                                                                  FROM Site_Visit_Inspection_Checklist__mdt	 
                                                                                  ORDER BY Sequence_No__c ASC];
        
        system.debug('inspectionCheckList'+inspectionCheckList);
        if(!inspectionCheckList.IsEmpty()){
            for(Site_Visit_Inspection_Checklist__mdt mdt :inspectionCheckList){
                returnList.add(mdt);
            }
        }
        return returnList;
    }
    
    
}