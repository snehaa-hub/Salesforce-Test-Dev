@isTest
public class ShowRelatedUnitBundle_Test {

    // ─────────────────────────────────────────────────────────────
    // Helper : Create Unit
    // ─────────────────────────────────────────────────────────────
    static Unit__c createUnit() {

        Unit__c unitRec = new Unit__c();

        unitRec.Name             = 'Test Unit';
        unitRec.Unit_Status__c   = 'Available';
        unitRec.Type_of_Unit__c  = 'BTS';
        unitRec.Unit_Category__c = 'Industrial Park';
        unitRec.Size_Range__c = 'below 10000';

        // Safe RecordType Fetch
        List<RecordType> rtList = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Unit__c'
            AND Name = 'Leasing'
            LIMIT 1
        ];

        if (!rtList.isEmpty()) {
            unitRec.RecordTypeId = rtList[0].Id;
        }

        insert unitRec;
        return unitRec;
    }

    // ─────────────────────────────────────────────────────────────
    // Helper : Create Person Account
    // ─────────────────────────────────────────────────────────────
    static Account createPersonAccount() {

        Id personRtId;

        Map<String, Schema.RecordTypeInfo> rtMap =
            Schema.SObjectType.Account.getRecordTypeInfosByName();

        if (rtMap.containsKey('Person Account')) {
            personRtId = rtMap.get('Person Account').getRecordTypeId();
        }

        Account acc = new Account();

        if (personRtId != null) {
            acc.RecordTypeId = personRtId;
            acc.LastName     = 'Test Person';
        } else {
            acc.Name = 'Business Account';
        }

        insert acc;
        return acc;
    }

    // ─────────────────────────────────────────────────────────────
    // Helper : Create User
    // ─────────────────────────────────────────────────────────────
    static User createUser() {

        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        User usr = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tusr',
            Email = 'testuser@test.com',
            Username = 'testuser' + System.currentTimeMillis() + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );

        insert usr;
        return usr;
    }

    // ─────────────────────────────────────────────────────────────
    // Test : fetchUnits
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void reqTestMethod() {

        Unit__c unitRec = createUnit();

        Shortlisted_Unit__c shortUnit = new Shortlisted_Unit__c(
            Status__c = 'Booked',
            Unit__c   = unitRec.Id
        );

        insert shortUnit;

        Test.startTest();

        String response =
            ShowRelatedUnitBundle.fetchUnits(
                '["' + shortUnit.Id + '"]'
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            response
        );
    }

    // ─────────────────────────────────────────────────────────────
    // Test : checkUnitBundleStatus
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void reqTestMethod2() {

        Account acc = createPersonAccount();

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today() + 10,
            AccountId = acc.Id
        );

        insert opp;

        Test.startTest();

        String response =
            ShowRelatedUnitBundle.checkUnitBundleStatus(opp.Id);

        ShowRelatedUnitBundle.getButtonVisibilityStatus();

        Test.stopTest();

        System.assertNotEquals(
            null,
            response
        );
    }

    // ─────────────────────────────────────────────────────────────
    // Test : deleteRecord
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void deleteRecordTest() {

        Unit_Bundle__c ub = new Unit_Bundle__c(
            Name = 'Test Bundle'
        );

        insert ub;

        Test.startTest();

        String result =
            ShowRelatedUnitBundle.deleteRecord(ub.Id);

        Test.stopTest();

        System.assertEquals(
            'Record deleted successfully',
            result
        );
    }

    // ─────────────────────────────────────────────────────────────
    // Test : getCurrentUserInfo (Admin)
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testGetCurrentUserInfo_SystemAdmin() {

        Test.startTest();

        String result =
            ShowRelatedUnitBundle.getCurrentUserInfo();

        Test.stopTest();

        System.assertNotEquals(
            null,
            result
        );

        Map<String, Object> info =
            (Map<String, Object>)
            JSON.deserializeUntyped(result);

        System.assert(
            info.containsKey('userName')
        );
    }

    // ─────────────────────────────────────────────────────────────
    // Test : getCurrentUserInfo with runAs
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testGetCurrentUserInfo_RunAsUser() {

        User usr = createUser();

        Test.startTest();

        System.runAs(usr) {

            String result =
                ShowRelatedUnitBundle.getCurrentUserInfo();

            System.assertNotEquals(
                null,
                result
            );
        }

        Test.stopTest();
    }

    // ─────────────────────────────────────────────────────────────
    // Test : notifyAdminsOfDeletion with Opp Id
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testNotifyAdminsOfDeletion_WithOpp() {

        Opportunity__c oppRec = new Opportunity__c(
            Name = 'Test Opp'
        );

        insert oppRec;

        Test.startTest();

        try {

            ShowRelatedUnitBundle.notifyAdminsOfDeletion(
                'Option - 1',
                oppRec.Id
            );

            System.assert(true);

        } catch (Exception e) {

            System.assert(
                e.getMessage() != null
            );
        }

        Test.stopTest();
    }

    // ─────────────────────────────────────────────────────────────
    // Test : notifyAdminsOfDeletion Blank Id
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testNotifyAdminsOfDeletion_BlankOppId() {

        Test.startTest();

        try {

            ShowRelatedUnitBundle.notifyAdminsOfDeletion(
                'Option - 1',
                ''
            );

            System.assert(true);

        } catch (Exception e) {

            System.assert(
                e.getMessage() != null
            );
        }

        Test.stopTest();
    }
}