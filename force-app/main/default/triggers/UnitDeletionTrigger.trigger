trigger UnitDeletionTrigger on Unit__c (before delete) {
    DeletionNotificationService.notifyOnDeletion(Trigger.old, 'Unit');
}