global class SiteVisitReminderBatch implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    
        return Database.getQueryLocator([
            SELECT Name, Id, Account__c, Account__r.PersonEmail, Visit_Date__c 
            FROM Site_Visit__c
            WHERE Account__r.PersonEmail != null 
            AND Visit_Date__c != null 
            AND (Visit_Date__c = :System.today() OR Visit_Date__c = :System.today().addDays(1))
        ]);
    }
    global void execute(Database.BatchableContext BC, List<Site_Visit__c> scope) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> emailTemp = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate 
                                         where DeveloperName =: 'Template_for_Informing_about_Scheduling_Site_Visit_to_Tenant' limit 1];
       
        if(!scope.isEmpty()){
            for(Site_Visit__c siteV:scope){
                system.debug('siteV==>'+siteV);
                   if(siteV.Visit_Date__c !=null){
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemp[0].Id, null, siteV.Id);
                    mail.setToAddresses(new List<String>{siteV.Account__r.PersonEmail});
                    mail.setSaveAsActivity(true);
                    mails.add(mail);  
                      }
                
            }
            if(!mails.isEmpty()){
               // Messaging.sendEmail(mails);
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    global void execute(SchedulableContext sc) {
        
        SiteVisitReminderBatch batch = new SiteVisitReminderBatch();
        Database.executeBatch(batch);
    }
}