trigger SiteVisitDeletionTrigger on Site_Visit__c (before delete) {
    DeletionNotificationService.notifyOnDeletion(Trigger.old, 'Site Visit');
}