@isTest
private class BirthdayNotificationBatchTest {

    @istest public static void mainmethod(){
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
        Account accountObject = new Account();
        accountObject.FirstName = 'test';
        accountObject.LastName = 'Account';
        accountObject.BillingCountry = 'India';
        accountObject.PersonBirthdate = System.today();
        accountObject.Phone = '455546565';
        accountObject.RecordTypeId = PersonRecId;
        accountObject.PersonEmail = 'dynamix.project@gmail.com';
        insert accountObject;
 		
        
        
        Test.startTest();
        BirthdayNotificationBatch ba= new BirthdayNotificationBatch();
        Id jobid= Database.executeBatch(ba);
        BirthdayNotificationBatch scheduler = new BirthdayNotificationBatch();
		scheduler.execute(null);
        Test.stopTest();
        //System.assertEquals(10, [SELECT Id,Owner.Email, PlannedVisitStartTime__c, Name, AccountName__c, Category__c, City__c FROM Visit__c where PlannedVisitStartTime__c  = 'TOMORROW']);
      
    }
}