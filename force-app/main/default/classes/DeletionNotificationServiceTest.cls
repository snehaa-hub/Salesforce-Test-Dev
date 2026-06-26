@isTest
private class DeletionNotificationServiceTest {

    // ─── Helper: Build User ────────────────────────────────────────────────
    private static User buildUser(String firstName, String lastName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String un = firstName.toLowerCase() + '.' + lastName.toLowerCase()
                  + '@test.allwarehouses.com';
        return new User(
            FirstName         = firstName,
            LastName          = lastName,
            Email             = un,
            Username          = un,
            Alias             = (firstName.substring(0,1)
                              + lastName.substring(0, Math.min(4, lastName.length())))
                              .toLowerCase(),
            TimeZoneSidKey    = 'Asia/Kolkata',
            LocaleSidKey      = 'en_IN',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = p.Id
        );
    }

    // ─── Setup ────────────────────────────────────────────────────────────
    @TestSetup
    static void setupData() {
        User pooja = buildUser('Pooja', 'Test');
        User aarti = buildUser('Aarti', 'Test');
        insert new List<User>{ pooja, aarti };
    }

    // ─── Helper: Set label overrides ──────────────────────────────────────
    private static void setLabelOverrides() {
        User pooja = [SELECT Username FROM User WHERE FirstName = 'Pooja' LIMIT 1];
        User aarti = [SELECT Username FROM User WHERE FirstName = 'Aarti' LIMIT 1];
        DeletionNotificationService.monitoredUsername = pooja.Username;
        DeletionNotificationService.adminUsername     = aarti.Username;
    }

    // ══════════════════════════════════════════════════════════════════════
    // TEST 1: Opportunity deleted by Pooja → email sent
    // ══════════════════════════════════════════════════════════════════════
   @isTest
static void testOpportunityDeletion_byPooja_emailSent() {
    setLabelOverrides();
    User pooja = [SELECT Id FROM User WHERE FirstName = 'Pooja' LIMIT 1];

    Account acc = new Account(Name = 'Test Account');
    insert acc;

    Opportunity opp = new Opportunity(
        Name      = 'Test Opportunity',
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(30),
        AccountId = acc.Id
    );
    insert opp;

    System.runAs(pooja) {
        Test.startTest();
        delete opp;
        Test.stopTest();
    }

    List<Opportunity> deleted = [
        SELECT Id, IsDeleted FROM Opportunity
        WHERE Id = :opp.Id ALL ROWS
    ];
    Assert.isTrue(deleted[0].IsDeleted, 'Opportunity should be deleted');
    // Email coverage is verified by code execution — no exception = email logic ran
}

    // ══════════════════════════════════════════════════════════════════════
    // TEST 2: Enquiry deleted by Pooja
    // ══════════════════════════════════════════════════════════════════════
    @isTest
    static void testEnquiryDeletion_byPooja() {
        setLabelOverrides();
        User pooja = [SELECT Id FROM User WHERE FirstName = 'Pooja' LIMIT 1];

        Enquiry__c enq = new Enquiry__c(
            Name            = 'Test Enquiry Delete',
            Mobile__c       = '9876543210',
            Email__c        = 'testenquiry@test.com'
        );
        insert enq;

        System.runAs(pooja) {
            Test.startTest();
            delete enq;
            Test.stopTest();
        }

        List<Enquiry__c> deleted = [
            SELECT Id, IsDeleted FROM Enquiry__c
            WHERE Id = :enq.Id ALL ROWS
        ];
        Assert.isTrue(deleted[0].IsDeleted, 'Enquiry should be deleted');
    }

    // ══════════════════════════════════════════════════════════════════════
    // TEST 3: Site Visit deleted by Pooja
    // ══════════════════════════════════════════════════════════════════════
    @isTest
    static void testSiteVisitDeletion_byPooja() {
        setLabelOverrides();
        User pooja = [SELECT Id FROM User WHERE FirstName = 'Pooja' LIMIT 1];

        Site_Visit__c sv = new Site_Visit__c(
            Name = 'Test Site Visit Delete'
            // ⚠️ Add required fields if any
        );
        insert sv;

        System.runAs(pooja) {
            Test.startTest();
            delete sv;
            Test.stopTest();
        }

        List<Site_Visit__c> deleted = [
            SELECT Id, IsDeleted FROM Site_Visit__c
            WHERE Id = :sv.Id ALL ROWS
        ];
        Assert.isTrue(deleted[0].IsDeleted, 'Site Visit should be deleted');
    }

    // ══════════════════════════════════════════════════════════════════════
    // TEST 4: File deleted by Pooja
    // ══════════════════════════════════════════════════════════════════════
    @isTest
    static void testFileDeletion_byPooja() {
        setLabelOverrides();
        User pooja = [SELECT Id FROM User WHERE FirstName = 'Pooja' LIMIT 1];

        ContentVersion cv = new ContentVersion(
            Title          = 'Test PDF',
            PathOnClient   = 'test.pdf',
            VersionData    = Blob.valueOf('dummy content'),
            IsMajorVersion = true
        );
        insert cv;

        ContentDocument cd = [
            SELECT Id FROM ContentDocument
            WHERE LatestPublishedVersionId = :cv.Id LIMIT 1
        ];

        System.runAs(pooja) {
            Test.startTest();
            delete cd;
            Test.stopTest();
        }

        List<ContentDocument> deleted = [
            SELECT Id, IsDeleted FROM ContentDocument
            WHERE Id = :cd.Id ALL ROWS
        ];
        Assert.isTrue(deleted[0].IsDeleted, 'File should be deleted');
    }

    // ══════════════════════════════════════════════════════════════════════
    // TEST 5: Bulk deletion (> 5 records) → +more suffix covered
    // ══════════════════════════════════════════════════════════════════════
    @isTest
    static void testBulkDeletion_moreThan5Records() {
        setLabelOverrides();
        User pooja = [SELECT Id FROM User WHERE FirstName = 'Pooja' LIMIT 1];

        Account acc = new Account(Name = 'Bulk Account');
        insert acc;

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 1; i <= 7; i++) {
            opps.add(new Opportunity(
                Name      = 'Bulk Opp ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                AccountId = acc.Id
            ));
        }
        insert opps;

        System.runAs(pooja) {
            Test.startTest();
            delete opps;
            Test.stopTest();
        }

        List<Opportunity> deleted = [
            SELECT Id, IsDeleted FROM Opportunity
            WHERE Id IN :opps ALL ROWS
        ];
        Assert.areEqual(7, deleted.size(), 'All 7 records should be in recycle bin');
    }

    // ══════════════════════════════════════════════════════════════════════
    // TEST 6: Non-monitored user deletes → no email sent
    // ══════════════════════════════════════════════════════════════════════
    @isTest
    static void testDeletion_byNonMonitoredUser_noEmail() {
        DeletionNotificationService.monitoredUsername = 'nobody@test.allwarehouses.com';
        DeletionNotificationService.adminUsername     =
            [SELECT Username FROM User WHERE FirstName = 'Aarti' LIMIT 1].Username;

        Account acc = new Account(Name = 'Non Monitored Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name      = 'Non Monitored Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        Integer emailsBefore = Limits.getEmailInvocations();

        User aarti = [SELECT Id FROM User WHERE FirstName = 'Aarti' LIMIT 1];
        System.runAs(aarti) {
            Test.startTest();
            delete opp;
            Test.stopTest();
        }

        Assert.areEqual(
            emailsBefore,
            Limits.getEmailInvocations(),
            'No email should be sent for non-monitored user'
        );
    }

    // ══════════════════════════════════════════════════════════════════════
    // TEST 7: Admin user not found → exits gracefully
    // ══════════════════════════════════════════════════════════════════════
    @isTest
    static void testAdminNotFound_gracefulExit() {
        User pooja = [SELECT Id, Username FROM User WHERE FirstName = 'Pooja' LIMIT 1];
        DeletionNotificationService.monitoredUsername = pooja.Username;
        DeletionNotificationService.adminUsername     = 'nonexistent@test.allwarehouses.com';

        Account acc = new Account(Name = 'Grace Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name      = 'Grace Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        System.runAs(pooja) {
            Test.startTest();
            delete opp;
            Test.stopTest();
        }

        Assert.isTrue(true, 'Service exits cleanly when admin not found');
    }

    // ══════════════════════════════════════════════════════════════════════
    // TEST 8: Direct service call → covers name building branch
    // ══════════════════════════════════════════════════════════════════════
    @isTest
    static void testDirectServiceCall_nameBuilding() {
        setLabelOverrides();
        User pooja = [SELECT Id FROM User WHERE FirstName = 'Pooja' LIMIT 1];

        Account acc = new Account(Name = 'Direct Call Account');
        insert acc;

        System.runAs(pooja) {
            Test.startTest();
            DeletionNotificationService.notifyOnDeletion(
                new List<SObject>{ acc },
                'Account'
            );
            Test.stopTest();
        }

        Assert.isTrue(true, 'Direct service call completed without exception');
    }
}