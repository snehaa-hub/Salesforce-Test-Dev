public class GetNegotiationChecklistMetadata {
    @AuraEnabled(cacheable = true)
    public static List<Object> execute(){
        List<Object>returnList = New List<Object>();
        List<Negotiation_Checklist__mdt	> negotiationCheckList = [SELECT Id,Label,MasterLabel, Additional_Value__c, 
                                                                                  IsHeading__c, IsMainHeading__c, 
                                                                                  IsSubLabel__c,
                                                                                  Sequence_No__c,
                                                                                  Text_Label__c,Datatype__c,
                                                                                  Default_Value__c,
                                                                                  Sub_With_single_column__c,
                                                                                  Disclaimer__c,
                                                                                  Location__c
                                                                                  FROM Negotiation_Checklist__mdt	 
                                                                                  ORDER BY Sequence_No__c ASC]; //ORDER BY Sequence_No__c ASC
        
        system.debug('negotiationCheckList'+negotiationCheckList);
        if(!negotiationCheckList.IsEmpty()){
            for(Negotiation_Checklist__mdt mdt :negotiationCheckList){
                returnList.add(mdt);
            }
        }
        return returnList;
    }
    
}