trigger ContentDocumentDeletionTrigger on ContentDocument (before delete) {
    DeletionNotificationService.notifyOnDeletion(Trigger.old, 'File');
}