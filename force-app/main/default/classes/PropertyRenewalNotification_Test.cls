@isTest
public class PropertyRenewalNotification_Test {
 @istest 
    public static void mainmethod(){
           Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User u = new User();
        u.FirstName = 'test';
        u.LastName = 'test';
        u.Alias = 'ttest';
        u.Email = 'test@gmail.com';
        u.Username = 'test1@gmail.comProject';
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
        accountObject.PersonEmail = 'test.project@gmail.com';
        insert accountObject;
 		 
        Unit__c unitData = new Unit__c();
        unitData.Name = 'Unit 1';
        unitData.Type_of_Unit__c = 'Land';
        unitData.City__c = 'City1';
        unitData.Country__c = 'Country1';
        unitData.Postal_Code__c = '12345';
        unitData.Chargeable_Area__c = 1500;
        unitData.State__c = 'State1';
        unitData.Street__c = 'Street1';
        unitData.Unit_Status__c = 'Available';
        unitData.Date_Available__c =system.today().addDays(30);
        unitData.Unit_Location__Latitude__s = 30.7333;
        unitData.Unit_Location__Longitude__s = 76.7794;
        unitData.Budget__c = '2.5 lakh to 5 lakh';
        unitData.OwnerId = u.Id;
        unitData.Size_Range__c = 'below 10000';

        Test.startTest();
        insert unitData;
        PropertyRenewalNotification ba= new PropertyRenewalNotification();
        Id jobid= Database.executeBatch(ba);
        PropertyRenewalNotification scheduler = new PropertyRenewalNotification();
		scheduler.execute(null);
        Test.stopTest();
       
    }
}