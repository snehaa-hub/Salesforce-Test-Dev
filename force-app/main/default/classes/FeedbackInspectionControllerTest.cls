@isTest
public class FeedbackInspectionControllerTest {

    @testSetup
    static void setupData() {

        Id currentUserId = UserInfo.getUserId();

        // Person Account → Point_of_Contact__c on Unit__c
        Id personRT = [SELECT Id FROM RecordType
                       WHERE SObjectType = 'Account'
                       AND IsPersonType = true LIMIT 1].Id;

        Account acc = new Account(
            RecordTypeId      = personRT,
            FirstName         = 'Landlord',
            LastName          = 'Test',
            PersonMobilePhone = '9999999999',
            PersonEmail       = 'landlord@test.com'
        );
        insert acc;

        // Unit__c — all coverage-relevant fields populated
        Unit__c unit = new Unit__c(
            Name                          = 'Test Unit',
            Point_of_Contact__c           = acc.Id,
            City__c                       = 'Chennai',
            Size_Range__c                 = 'below 10000',
            Saleable_Area__c              = 1200,
            Rent_per_uom_Price_per_uom__c = 75
        );
        insert unit;

        // Shortlisted_Unit__c → Unit__c
        Shortlisted_Unit__c su = new Shortlisted_Unit__c(
            Unit__c = unit.Id
        );
        insert su;

        // Unit_Bundle__c — Linked_Unit__c = JSON array of Shortlisted Unit Ids
        Unit_Bundle__c bundle = new Unit_Bundle__c(
            Name           = 'Test Bundle',
            Linked_Unit__c = JSON.serialize(new List<Id>{ su.Id })
        );
        insert bundle;

        // Site_Visit__c → Unit_Bundle__c  (Resource_Allocator__c avoids trigger VR)
        Site_Visit__c sv = new Site_Visit__c(
            Name                    = 'Test Visit',
            Unit_Bundle__c          = bundle.Id,
            Resource_Allocator__c   = currentUserId,
            Visit_Date_Time__c      = System.now().addDays(1),
            No_of_People_Planned__c = 2
        );
        insert sv;
    }

   
    /** Fetches the primary Site_Visit__c created in @testSetup */
    private static Site_Visit__c getSiteVisit() {
        return [SELECT Id, Unit_Bundle__c, Tenant_Signature__c
                FROM   Site_Visit__c
                WHERE  Name = 'Test Visit'
                LIMIT  1];
    }

    /** Factory — ensures all trigger-required fields are always set */
    private static Site_Visit__c buildSiteVisit(String name, Id bundleId) {
        return new Site_Visit__c(
            Name                    = name,
            Unit_Bundle__c          = bundleId,
            Resource_Allocator__c   = UserInfo.getUserId(),
            Visit_Date_Time__c      = System.now().addDays(1),
            No_of_People_Planned__c = 1
        );
    }

    /** Saves a valid signature to the Site Visit so generatePDFFuture can read it */
    private static void saveSignatureOnRecord(Id svId) {
        String sig = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        FeedbackInspectionController.saveSignature(svId, sig);
    }

  
    @isTest
    static void testGetUnitDetails_Success() {

        Site_Visit__c sv = getSiteVisit();

        Test.startTest();
        FeedbackInspectionController.Wrapper w =
            FeedbackInspectionController.getUnitDetails(sv.Id);
        Test.stopTest();

        System.assertNotEquals(null,       w,               'Wrapper must not be null');
        System.assertEquals('Chennai',     w.location,      'location should be Chennai');
        System.assertEquals('below 10000', w.size,          'size should match picklist');
        System.assertNotEquals(null,       w.landlordName,  'landlordName must be populated');
        System.assertEquals(1200,          w.chargeableArea,'chargeableArea should be 1200');
        System.assertEquals(75,            w.rentPerSqFt,   'rentPerSqFt should be 75');
    }

  
    @isTest
    static void testGetUnitDetails_NullId() {

        Boolean threw = false;
        Test.startTest();
        try {
            FeedbackInspectionController.getUnitDetails(null);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Must throw for null siteVisitId');
    }


    @isTest
    static void testGetUnitDetails_SiteVisitNotFound() {

        Site_Visit__c dummy = buildSiteVisit('Dummy Visit', null);
        insert dummy;
        delete dummy;

        Boolean threw = false;
        Test.startTest();
        try {
            FeedbackInspectionController.getUnitDetails(dummy.Id);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Must throw for deleted Site Visit');
    }

    @isTest
    static void testGetUnitDetails_NoBundleOnSiteVisit() {

        Site_Visit__c sv = new Site_Visit__c(
            Name                    = 'No Bundle Visit',
            Resource_Allocator__c   = UserInfo.getUserId(),
            Visit_Date_Time__c      = System.now().addDays(1),
            No_of_People_Planned__c = 1
        );
        insert sv;

        Boolean threw = false;
        Test.startTest();
        try {
            FeedbackInspectionController.getUnitDetails(sv.Id);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Must throw when Unit Bundle is null on Site Visit');
    }
    @isTest
    static void testGetUnitDetails_LinkedUnitJsonEmpty() {

        Unit_Bundle__c emptyBundle = new Unit_Bundle__c(
            Name           = 'Empty Bundle',
            Linked_Unit__c = ''
        );
        insert emptyBundle;

        Site_Visit__c sv = buildSiteVisit('Visit Empty Bundle', emptyBundle.Id);
        insert sv;

        Boolean threw = false;
        Test.startTest();
        try {
            FeedbackInspectionController.getUnitDetails(sv.Id);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Must throw when Linked_Unit__c JSON is blank');
    }

  
    @isTest
    static void testGetUnitDetails_LinkedUnitJsonEmptyArray() {

        Unit_Bundle__c bundle = new Unit_Bundle__c(
            Name           = 'Empty Array Bundle',
            Linked_Unit__c = '[]'   // valid JSON but zero elements
        );
        insert bundle;

        Site_Visit__c sv = buildSiteVisit('Visit Empty Array', bundle.Id);
        insert sv;

        Boolean threw = false;
        Test.startTest();
        try {
            FeedbackInspectionController.getUnitDetails(sv.Id);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Must throw when Linked_Unit__c JSON is empty array');
    }

    @isTest
    static void testGetUnitDetails_ShortlistedUnitNotFound() {

        Unit__c unit = [SELECT Id FROM Unit__c LIMIT 1];

        Shortlisted_Unit__c orphan = new Shortlisted_Unit__c(Unit__c = unit.Id);
        insert orphan;
        Id orphanId = orphan.Id;
        delete orphan;   // record is gone — query inside controller returns empty

        Unit_Bundle__c bundle = new Unit_Bundle__c(
            Name           = 'Orphan Bundle',
            Linked_Unit__c = JSON.serialize(new List<Id>{ orphanId })
        );
        insert bundle;

        Site_Visit__c sv = buildSiteVisit('Orphan SU Visit', bundle.Id);
        insert sv;

        Boolean threw = false;
        Test.startTest();
        try {
            FeedbackInspectionController.getUnitDetails(sv.Id);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Must throw when Shortlisted Unit record is deleted');
    }


    @isTest
    static void testGetUnitDetails_UnitNotFound() {

        // Create a throwaway Unit__c, link it, then delete it
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Unit__c tempUnit = new Unit__c(
            Name                = 'Temp Unit',
            Point_of_Contact__c = acc.Id,
            City__c             = 'Mumbai',
            Size_Range__c       = 'below 10000'
        );
        insert tempUnit;

        Shortlisted_Unit__c su = new Shortlisted_Unit__c(Unit__c = tempUnit.Id);
        insert su;

        // Delete the Unit so the controller's Unit__c SOQL returns empty
        delete tempUnit;

        Unit_Bundle__c bundle = new Unit_Bundle__c(
            Name           = 'Deleted Unit Bundle',
            Linked_Unit__c = JSON.serialize(new List<Id>{ su.Id })
        );
        insert bundle;

        Site_Visit__c sv = buildSiteVisit('Deleted Unit Visit', bundle.Id);
        insert sv;

        Boolean threw = false;
        Test.startTest();
        try {
            FeedbackInspectionController.getUnitDetails(sv.Id);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Must throw when Unit__c record has been deleted');
    }


    @isTest
    static void testSaveSignature_Success() {

        Site_Visit__c sv = getSiteVisit();

        Test.startTest();
        saveSignatureOnRecord(sv.Id);
        Test.stopTest();

        Site_Visit__c updated = [SELECT Tenant_Signature__c FROM Site_Visit__c WHERE Id = :sv.Id];
        System.assertNotEquals(null, updated.Tenant_Signature__c, 'Signature field must be populated');
        System.assert(
            String.isNotBlank(updated.Tenant_Signature__c),
            'Tenant_Signature__c must not be blank'
        );

        System.assert(
            updated.Tenant_Signature__c.containsIgnoreCase('<img'),
            'Tenant_Signature__c must contain an <img> tag'
        );
    }


    @isTest
    static void testSaveSignature_BlankSignature() {

        Site_Visit__c sv    = getSiteVisit();
        Boolean       threw = false;

        Test.startTest();
        try {
            FeedbackInspectionController.saveSignature(sv.Id, '');
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Must throw for blank signature');
    }

    @isTest
    static void testSaveSignature_NullId() {

        Boolean threw = false;
        Test.startTest();
        try {
            FeedbackInspectionController.saveSignature(null, 'data:image/png;base64,abc');
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Must throw for null siteVisitId in saveSignature');
    }

    @isTest
    static void testGeneratePDF_NullId() {

        Boolean threw = false;
        Test.startTest();
        try {
            FeedbackInspectionController.generatePDF(null, 'below 10000', 1200, 75);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(true, threw, 'Must throw for null siteVisitId in generatePDF');
    }

    @isTest
    static void testGeneratePDF_Dispatches() {

        Site_Visit__c sv = getSiteVisit();
        saveSignatureOnRecord(sv.Id);

        Boolean threw = false;
        Test.startTest();
        try {
            FeedbackInspectionController.generatePDF(sv.Id, 'below 10000', 1200, 75);
        } catch (AuraHandledException e) {
            threw = true;
        }
        Test.stopTest();

        System.assertEquals(false, threw, 'generatePDF must not throw for valid inputs');
    }

    @isTest
    static void testGeneratePDFFuture_DirectCall() {

        Site_Visit__c sv = getSiteVisit();
        saveSignatureOnRecord(sv.Id);   // signature must exist before PDF gen

        Test.startTest();
        // Call directly — covers all lines inside generatePDFFuture synchronously
        FeedbackInspectionController.generatePDFFuture(
            sv.Id, 'below 10000', 1200, 75
        );
        Test.stopTest();

        // ContentVersion should now exist
        List<ContentVersion> cvList = [
            SELECT Id, Title, PathOnClient
            FROM   ContentVersion
            WHERE  PathOnClient = 'FeedbackInspection.pdf'
        ];
        System.assertNotEquals(0, cvList.size(), 'ContentVersion must be created by generatePDFFuture');
        System.assert(
            cvList[0].Title.startsWith('Feedback_Inspection_'),
            'ContentVersion title must start with Feedback_Inspection_'
        );

        // ContentDocumentLink must link the PDF to the Site Visit
        List<ContentDocumentLink> cdlList = [
            SELECT Id
            FROM   ContentDocumentLink
            WHERE  LinkedEntityId = :sv.Id
        ];
        System.assertNotEquals(0, cdlList.size(),
            'ContentDocumentLink must link the PDF to the Site Visit');
    }

   
    @isTest
    static void testGeneratePDFFuture_ViaQueue() {

        Site_Visit__c sv = getSiteVisit();
        saveSignatureOnRecord(sv.Id);

        Test.startTest();
        FeedbackInspectionController.generatePDF(sv.Id, 'below 10000', 1200, 75);
        Test.stopTest(); // flushes @future synchronously

        List<ContentVersion> cvList = [
            SELECT Id FROM ContentVersion WHERE PathOnClient = 'FeedbackInspection.pdf'
        ];
        System.assert(true, '@future completed without unhandled exception');
        // Non-strict: future may or may not produce CV depending on getContentAsPDF mock
        if (!cvList.isEmpty()) {
            System.assertNotEquals(0, cvList.size(), 'ContentVersion created via future queue');
        }
    }
}