@istest 
public class SiteVisitReminderBatch_Test {
@istest 
    public static void mainmethod(){
         Profile pf= [Select Id from profile where Name='System Administrator']; 
        User u = new User();
        u.FirstName = 'test';
        u.LastName = 'test';
        u.Alias = 'ttest';
        u.Email = 'test@gmail.com';
        u.Username = 'test@gmail.com.stylam2022';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = pf.Id;
        INSERT u;
        
       Id PersonRecId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();
  			
        	Account acc = new Account();
            acc.RecordTypeID = PersonRecId;
            acc.FirstName = 'Test';
            acc.LastName = 'User';
            acc.PersonEmail = 'TestUser@gmail.com';
            acc.PersonMobilePhone = '65464453435';
            acc.Salutation = 'Mr';
            insert acc;
    		Enquiry__c enquiry = new Enquiry__c();
            enquiry.Status__c='New';
        enquiry.Mobile__c = '7896541236';
            insert enquiry; 
            Site_Visit__c siteVisit = new Site_Visit__c();
            siteVisit.Enquiry__c = enquiry.Id;
            siteVisit.Status__c = 'Scheduled';
        	siteVisit.Account__c =acc.id;
        	siteVisit.Visit_Date_Time__c = system.now()+1;
            insert siteVisit;
       
        
        
        Test.startTest();
        SiteVisitReminderBatch ba= new SiteVisitReminderBatch();
        Id jobid= Database.executeBatch(ba);
        SiteVisitReminderBatch scheduler = new SiteVisitReminderBatch();
		scheduler.execute(null);
        Test.stopTest();
       
    }
}