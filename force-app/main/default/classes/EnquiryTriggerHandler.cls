public class EnquiryTriggerHandler {


   

     public static void sendEnquiryNotification(List<Enquiry__c> newEnquiries) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
		System.debug('newEnquiries***' + newEnquiries);
        Id templateId = [SELECT Id, Name, DeveloperName, FolderName, Subject FROM EmailTemplate where DeveloperName = 'Welcome_Email'].Id;
		System.debug('templateId***' + templateId);
        for (Enquiry__c enquiry : newEnquiries) {
            if (String.isNotBlank(enquiry.Email__c)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(templateId);
                mail.setTargetObjectId(enquiry.OwnerId);
                mail.setToAddresses(new String[] { enquiry.Email__c });
                mail.setSaveAsActivity(false);
                emailsToSend.add(mail);
            }
        }
		System.debug('emailsToSend***' + emailsToSend);
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
}