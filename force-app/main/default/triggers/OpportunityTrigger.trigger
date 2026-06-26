trigger OpportunityTrigger on Opportunity__c (before insert ,before update) {
	
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OpportunityHandler.stageInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            OpportunityHandler.StageUpdated(Trigger.new, Trigger.oldMap);
        }
    }
}