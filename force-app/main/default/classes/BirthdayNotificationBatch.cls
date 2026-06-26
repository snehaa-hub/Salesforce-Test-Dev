global class BirthdayNotificationBatch implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Name, PersonBirthdate,PersonEmail FROM Account where PersonBirthdate != null
        ]);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> emailTemp = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate 
                                         where DeveloperName =: 'Birthday_Greeting' limit 1];
        if(!scope.isEmpty()){
            for(Account acc:scope){
                if(acc.PersonBirthdate.day()==system.today().day() && acc.PersonBirthdate.month()==system.today().month()){
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemp[0].Id, null, acc.Id);
                    mail.setToAddresses(new List<String>{acc.PersonEmail});
                    mail.setSaveAsActivity(true);
                    mails.add(mail);
                }
            }
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    global void execute(SchedulableContext sc) {
        
        BirthdayNotificationBatch batch =new BirthdayNotificationBatch();
        Database.executeBatch(batch);
    }
}