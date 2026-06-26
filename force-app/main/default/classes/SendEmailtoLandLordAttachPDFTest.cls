@istest
public class SendEmailtoLandLordAttachPDFTest {
    
    @testSetup
    static void setupData() {
        
        // Get the System Administrator profile
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create a user with that profile
        User sysAdminUser = new User(
            FirstName = 'Test',
            LastName = 'Admin',
            Email = 'testadmin@example.com',
            Username = 'testadmin' + DateTime.now().getTime() + '@example.com',
            Alias = 'tadmin',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = sysAdminProfile.Id
        );
        insert sysAdminUser;
        
        // Run your logic as that user
        System.runAs(sysAdminUser) {
            // Step 1: Create a test Contact
            RecordType personAccountRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true LIMIT 1];
            
            // Step 2: Create and insert the Person Account
            Account poc = new Account(
                RecordTypeId = personAccountRT.Id,
                LastName = 'Test Landlord', // Required field for Person Accounts
                PersonEmail = 'landlord@example.com'
            );
            insert poc;
            
            // Step 2: Create Unit__c records with Point_of_Contact__c field pointing to the contact
            List<Unit__c> units = new List<Unit__c>();
            for (Integer i = 0; i < 2; i++) {
                units.add(new Unit__c(
                    Name = 'Unit ' + i,
                    City__c = 'TestCity' + i,
                    Point_of_Contact__c = poc.Id,
                    Size_Range__c = 'below 10000'
                ));
            }
            insert units;
            
            // Step 3: Create a dummy EmailTemplate
            EmailTemplate template = new EmailTemplate(
                Name = 'Site Visit Completed',
                DeveloperName = 'Template_for_Site_Visit_Completed_Landlord',
                FolderId = UserInfo.getUserId(), // or use a valid public folder ID
                TemplateType = 'text', // or 'html' or 'visualforce' depending on your use
                Subject = 'Your site visit is complete',
                Body = 'Hello, your site visit has been completed successfully.'
            );
            insert template;
        }
    }
    
    @isTest
    static void testSendEmailWithPDFs() {
        // Step 1: Get test Unit IDs
       // List<Unit__c> testUnits = [SELECT Id FROM Unit__c];
        //List<String> unitIds = new List<String>();
       // for (Unit__c u : testUnits) unitIds.add(u.Id);
        
        Account personAccount = new Account(
            FirstName = 'Test',
            LastName = 'Dev',
            PersonEmail = 'landlord@example.com'
        );
        insert personAccount;

        Unit__c testUnit = new Unit__c(
            Name = 'Unit A101',
            City__c = 'Chennai',
            Date_Available__c = Date.today().addDays(5),
            Point_of_Contact__c = personAccount.Id,
            Size_Range__c = 'below 10000'
        );
        insert testUnit;
		
        Shortlisted_Unit__c shortUnit = new Shortlisted_Unit__c(
        	
           Unit__c = testUnit.Id
        );
		insert shortUnit;
        
        Unit_Bundle__c unitBundle = new Unit_Bundle__c(
        Name = 'test1',
        Linked_Unit__c = JSON.serialize(new List<String>{ shortUnit.Id })
        );
        insert unitBundle;
        Site_Visit__c siteVisits = new Site_Visit__c(
        Name = 'test2',
        Closed_Date__c = System.today() 
        );
        insert siteVisits;
        
        // Step 2: Prepare input wrapper
        SendEmailtoLandLordAttachPdf.InputWrapper input = new SendEmailtoLandLordAttachPdf.InputWrapper();
        input.UnitBundleId = unitBundle.Id;
        input.SiteIds  = siteVisits.Id;
        
        // Step 3: Mock PDF generation (assuming your ImagePDFGenerator handles Test.isRunningTest())
        Test.startTest();
        SendEmailtoLandLordAttachPdf.getUnitRecords(new List<SendEmailtoLandLordAttachPdf.InputWrapper>{input});
        Test.stopTest();
        
        // Step 4: Basic validation
        List<ContentVersion> createdPdfs = [SELECT Id FROM ContentVersion WHERE Title = 'GeneratedImagePDF'];
        System.assert(!createdPdfs.isEmpty(), 'Expected PDF ContentVersion records to be created.');
    }
    
}