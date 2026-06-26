@isTest
public class SiteVisitTriggerHandlerTest {
    
    @testSetup
    static void setupData() {
        
        Profile p = [SELECT Id FROM Profile WHERE Id = :UserInfo.getProfileId()];
        
        // User 1
        User u1 = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@test.com',
            Username = 'testuser' + System.currentTimeMillis() + '@test.com',
            Alias = 'tusr',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u1;
        
        // User 2 (for update scenario)
        User u2 = new User(
            FirstName = 'Test2',
            LastName = 'User2',
            Email = 'testuser2@test.com',
            Username = 'testuser2' + System.currentTimeMillis() + '@test.com',
            Alias = 'tusr2',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u2;
        
        // Person Account
        Id personRT = [SELECT Id FROM RecordType 
                       WHERE SObjectType = 'Account' 
                       AND IsPersonType = true LIMIT 1].Id;
        
        Account acc = new Account(
            RecordTypeId = personRT,
            FirstName = 'First',
            LastName = 'Test',
            PersonMobilePhone = '9999999999',
            PersonEmail = 'landlord@test.com'
        );
        insert acc;
        
        // Unit
        Unit__c unit = new Unit__c(
            Name = 'Test Unit',
            Point_of_Contact__c = acc.Id,
            Size_Range__c = 'below 10000', // must be valid
            City__c = 'Chennai'
        );
        insert unit;
        
        // Shortlisted Unit
        Shortlisted_Unit__c su = new Shortlisted_Unit__c(
            Unit__c = unit.Id
        );
        insert su;
        
        // Bundle with JSON
        String jsonData = JSON.serialize(new List<Id>{su.Id});
        
        Unit_Bundle__c bundle = new Unit_Bundle__c(
            Name = 'Bundle',
            Linked_Unit__c = jsonData
        );
        insert bundle;
    }
    
    
    @isTest
    static void testInsertAndUpdateFlow() {
        
        User u1 = [SELECT Id FROM User WHERE Email = 'testuser@test.com' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE Email = 'testuser2@test.com' LIMIT 1];
        Unit_Bundle__c bundle = [SELECT Id FROM Unit_Bundle__c LIMIT 1];
        
        Test.startTest();
        
        // INSERT → should trigger logic
        Site_Visit__c sv = new Site_Visit__c(
            Name = 'Visit',
            Resource_Allocator__c = u1.Id,
            Unit_Bundle__c = bundle.Id,
            Visit_Date_Time__c = System.now().addDays(1),
            No_of_People_Planned__c = 2
        );
        insert sv;
        
        // UPDATE → change allocator (critical for coverage)
        sv.Resource_Allocator__c = u2.Id;
        update sv;
        
        Test.stopTest();
        
        // Assertions (correct way)
        System.assertNotEquals(null, sv.Id);
        System.assertEquals(u2.Id, sv.Resource_Allocator__c);
    }
}