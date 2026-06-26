public class ScheduledEmailSender implements Schedulable {
    public void execute(SchedulableContext sc) {
       
        Account acc = [SELECT id, Name, PersonEmail from Account WHERE PersonEmail != null LIMIT 1];

        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(acc.Id);
        mail.setTemplateId('00X5g000001abcd'); 
        mail.setSaveAsActivity(false);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}