global class PropertyRenewalNotification implements Database.Batchable<SObject>, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date reminderDate = System.today().addDays(30);
         return Database.getQueryLocator([
            
            SELECT Id, Name, Owner.Email, Date_Available__c FROM Unit__c
             WHERE Date_Available__c = : reminderDate AND Date_Available__c != null
        ]);   
    }
    global void execute(Database.BatchableContext BC, List<Unit__c> scope) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> emailTemp = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate 
                                         where DeveloperName =: 'Property_Renewal' limit 1];
        if(!scope.isEmpty()){
            for(Unit__c unit:scope){
                 if(unit.Date_Available__c != null){
                  // Date reminderDate = unit.Date_Available__c.addDays(-30);
                   //if(reminderDate !=null){
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemp[0].Id, null, unit.Id);
                    mail.setToAddresses(new List<String>{unit.owner.Email});
                    mail.setSaveAsActivity(true);
                    mails.add(mail);   
                   //} 
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
        
        PropertyRenewalNotification batch =new PropertyRenewalNotification();
        Database.executeBatch(batch);
    }
}