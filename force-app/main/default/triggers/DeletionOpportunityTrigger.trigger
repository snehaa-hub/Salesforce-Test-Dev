trigger DeletionOpportunityTrigger on Opportunity (before delete) {
    DeletionNotificationService.notifyOnDeletion(Trigger.old, 'Opportunity');
}