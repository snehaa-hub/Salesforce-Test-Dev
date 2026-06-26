trigger EnquiryDeletionTrigger on Enquiry__c (before delete) {
    DeletionNotificationService.notifyOnDeletion(Trigger.old, 'Enquiry');
}