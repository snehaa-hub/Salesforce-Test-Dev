@istest
public class SendEmailAndNotification_Test {
    
    @TestSetup
    static void setupData() {
        // Create Contact
        Contact con = new Contact(
            LastName = 'Contact1',
            Email = 'contact1@example.com'
        );
        insert con;

        // Create Enquiry
        Enquiry__c enquiry = new Enquiry__c(
            Name = 'Test Enquiry',
            Size_in_sqfts__c = 1200,
            Mobile__c = '9876543210'
        );
        insert enquiry;

        // Create Opportunity
        Opportunity__c opp = new Opportunity__c(
            Name = 'Test Opportunity',
            Enquiry__c = enquiry.Id
        );
        insert opp;

        // ContentVersion (attachment)
        ContentVersion cv = new ContentVersion(
            Title = 'SamplePDF',
            PathOnClient = 'Sample.pdf',
            VersionData = Blob.valueOf('PDF Content')
        );
        insert cv;

        // Email Template
        System.runAs(new User(Id = UserInfo.getUserId())) {
            EmailTemplate et = new EmailTemplate(
                Name = 'TestTemplate',
                DeveloperName = 'TestTemplate1',
                FolderId = UserInfo.getUserId(),
                TemplateType = 'custom',
                Subject = 'Proposal for #Name (#Squarefeet)',
                HtmlValue = '<html><body>Hello {!Contact.Name}</body></html>',
                Body = 'Plain text body for {!Contact.Name}',
                IsActive = true
            );
            insert et;
        }
    }

    @IsTest
    static void testSendEmailWithContactAndTemplate() {
        Test.startTest();

        Contact con = [SELECT Id, Email FROM Contact LIMIT 1];
        Opportunity__c opp = [SELECT Id FROM Opportunity__c LIMIT 1];
        EmailTemplate et = [SELECT Id FROM EmailTemplate LIMIT 1];
        ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion LIMIT 1];

        SendEmailAndNotification.Request req = new SendEmailAndNotification.Request();
        req.recordId = opp.Id;
        req.sendEmail = true;
        req.sendNotification = true;
        req.emailTemplateId = et.Id;
        req.landemailTemplateId = et.Id;
        req.notificationTypeId = '00XFakeNotificationId';
        req.title = 'Test Email Subject';
        req.body = 'This is a test email body';
        req.ContactList = new List<Contact>{ con };
        req.emailList = new List<String>{ con.Email };
        req.emailLandList = new List<String>{ 'landlord@example.com' };
        req.contentVersionList = new List<ContentVersion>{ cv };
        req.userList = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        SendEmailAndNotification.execute(new List<SendEmailAndNotification.Request>{ req });
        Test.stopTest();
    }

    @IsTest
    static void testSendEmailWithoutContact() {
        Test.startTest();

        Opportunity__c opp = [SELECT Id FROM Opportunity__c LIMIT 1];
        EmailTemplate et = [SELECT Id FROM EmailTemplate LIMIT 1];
        ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion LIMIT 1];

        SendEmailAndNotification.Request req = new SendEmailAndNotification.Request();
        req.recordId = opp.Id;
        req.sendEmail = true;
        req.emailTemplateId = et.Id;
        req.landemailTemplateId = et.Id;
        req.ContactList = new List<Contact>();
        req.emailList = new List<String>{ 'customer@example.com' };
        req.emailLandList = new List<String>{ 'landlord@example.com' };
        req.contentVersionList = new List<ContentVersion>{ cv };

        SendEmailAndNotification.execute(new List<SendEmailAndNotification.Request>{ req });
        Test.stopTest();
    }

    @IsTest
    static void testSendNotificationOnly() {
        Test.startTest();

        Opportunity__c opp = [SELECT Id FROM Opportunity__c LIMIT 1];
        EmailTemplate et = [SELECT Id FROM EmailTemplate LIMIT 1];

        SendEmailAndNotification.Request req = new SendEmailAndNotification.Request();
        req.recordId = opp.Id;
        req.sendEmail = false;
        req.sendNotification = true;
        req.notificationTypeId = '00XFakeNotificationId';
        req.title = 'Notification Title';
        req.body = 'Notification Body';
        req.emailTemplateId = et.Id;
        req.userList = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        SendEmailAndNotification.execute(new List<SendEmailAndNotification.Request>{ req });
        Test.stopTest();
    }

    @IsTest
    static void testSendEmailWithTitleAndBody() {
        Test.startTest();

        Contact con = [SELECT Id, Email FROM Contact LIMIT 1];
        Opportunity__c opp = [SELECT Id FROM Opportunity__c LIMIT 1];

        SendEmailAndNotification.Request req = new SendEmailAndNotification.Request();
        req.recordId = opp.Id;
        req.sendEmail = true;
        req.title = 'Direct Subject';
        req.body = 'This is a raw email body';
        req.ContactList = new List<Contact>{ con };

        SendEmailAndNotification.execute(new List<SendEmailAndNotification.Request>{ req });
        Test.stopTest();
    }

    @IsTest
    static void testSendEmailWithEmptyContactsAndTemplate() {
        Test.startTest();

        Opportunity__c opp = [SELECT Id FROM Opportunity__c LIMIT 1];
        EmailTemplate et = [SELECT Id FROM EmailTemplate LIMIT 1];

        SendEmailAndNotification.Request req = new SendEmailAndNotification.Request();
        req.recordId = opp.Id;
        req.sendEmail = true;
        req.emailTemplateId = et.Id;
        req.landemailTemplateId = et.Id;
        req.ContactList = new List<Contact>();
        req.emailList = new List<String>{ 'testuser@example.com' };
        req.emailLandList = new List<String>{ 'landlord@example.com' };

        SendEmailAndNotification.execute(new List<SendEmailAndNotification.Request>{ req });
        Test.stopTest();
    }
}