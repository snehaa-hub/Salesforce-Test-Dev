/* 
     *@description       : Whenever the deal breaks in the path, we should know in which stage it was breaked
	  @author            : 
	  @last modified on  : 29/04/2025
      
*/
public class OpportunityHandler {
    
    /*
     @description  Used to Update the Current Stage name
		@param oppList - use to get  list oppList
			@param oppList - use to get  list oldMap
		
     */
    public static void StageUpdated(List<Opportunity__c> oppList,Map<Id,Opportunity__c> oldMap){
        
        Map<String, String> stagePicklistLabels = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Opportunity__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            stagePicklistLabels.put(picklistEntry.getValue(), picklistEntry.getLabel());
        }
        
        for (Opportunity__c opp : oppList) {
            Opportunity__c oldOpp = oldMap.get(opp.Id);
            
            if (opp.Stage__c != oldOpp.Stage__c) {
                opp.Previous_Stage__c = stagePicklistLabels.get(oldOpp.Stage__c);
                opp.Current_Stage__c = stagePicklistLabels.get(opp.Stage__c);
            }
        }
    }
    /*
     @description  Used to insert the Current Stage name
        @param oppList - use to get  list oppList
     */
    public static void stageInsert(List<Opportunity__c> oppList) {
    for (Opportunity__c opp : oppList) {
        opp.Current_Stage__c = 'Qualified';
    }
    
}
    @AuraEnabled(cacheable=true)
  public static Opportunity__c getOpportunity(Id opportunityId) {
    return [SELECT Id, Property_Type__c FROM Opportunity__c WHERE Id = :opportunityId LIMIT 1];
}
}