@isTest
private class UnitTriggerHandlerTest {

    @isTest
    static void testInterestEnquiriesNotification() {
        // Create mock Enquiry (Qualified and with email)
         RecordType rt = [SELECT Id, Name FROM RecordType 
                 WHERE DeveloperName = 'Tenant' 
                 AND SObjectType = 'Enquiry__c' 
                 LIMIT 1];
        Enquiry__c enquiry = new Enquiry__c(
            Name = 'Test Enquiry',
            Email__c = 'testuser@example.com',
            Type_of_Unit__c = 'Land', // match with unit
            Status__c ='Closed',
            Mobile__c ='1111100076',
            Reason_for_Closed__c = 'Qualified',
            Size_in_sqfts__c =1234,
            Size_in_sqft__c ='25000 - 50000',
            RecordTypeId =rt.Id
        );
        insert enquiry;

        // Create Interested Location within 5km radius of the Unit
        Interested_Locations__c interestedLoc = new Interested_Locations__c(
            Address__Latitude__s = 12.8728,     // near Urapakkam
            Address__Longitude__s = 80.0823,
            Related_Enquiry__c = enquiry.Id,
            Interested_Location_Range__c = 5
        );
        insert interestedLoc;

        // Create Unit within 5km of the interested location
        Unit__c unit = new Unit__c(
            Name = 'Unit 101',
            Google_Coordinates_Link__c ='https://maps.app.goo.gl/aqijgoWkhvHdbgf66',
            Unit_Location__Latitude__s = 12.8730,
            Unit_Location__Longitude__s = 80.0825,
            Size_Range__c ='25000 - 50000',
            Type_of_Unit__c = 'Land'
        );
        insert unit;

        // Simulate oldMap as null for creation scenario
        Test.startTest();
        UnitTriggerHandler.interestEnquiriesNotification(
            new List<Unit__c>{unit},
            null
        );
        Test.stopTest();

        // There's no assert for emails sent, but we can check debug logs manually if needed.
        // You may also use limits check if required:
       // System.assertEquals(1, Limits.getEmailInvocations(), 'One email should be sent');
    }


    @isTest
    static void testGeoCoordinatesExtractor_Insert() {
		Test.startTest();
        // Create a Unit__c record with a short Google URL
        Unit__c unit = new Unit__c(
            Name = 'Test Unit',
            Google_Coordinates_Link__c = 'https://maps.app.goo.gl/FqmhiAftreh9UCgJ6',
            Size_Range__c ='25000 - 50000'
        );
        insert unit;

        // Simulate insert trigger call
        UnitTriggerHandler.checkDuplicateNewUnit(new List<Unit__c>{unit});
        UnitTriggerHandler.GeoCoordinatesExtractor(
            new List<Unit__c>{unit}, 
            null
        );
        Test.stopTest();

        // Query and assert updated lat/lon values
        Unit__c updatedUnit = [SELECT Id, Unit_Location__Latitude__s, Unit_Location__Longitude__s FROM Unit__c WHERE Id = :unit.Id];
        System.assertEquals(12.8629364, updatedUnit.Unit_Location__Latitude__s);
        System.assertEquals(80.0759706, updatedUnit.Unit_Location__Longitude__s);
    }

    @isTest
    static void testGeoCoordinatesExtractor_Update() {
		Test.startTest();
        // Create and insert a Unit__c record
        Unit__c unit = new Unit__c(
            Name = 'Test Unit 2',
            Google_Coordinates_Link__c = 'https://maps.app.goo.gl/originalLink',
            Size_Range__c ='25000 - 50000'
        );
        insert unit;
       

        // Simulate update with changed Google URL
        Unit__c updated = new Unit__c();
        updated.Id = unit.Id;
        updated.Google_Coordinates_Link__c = 'https://maps.app.goo.gl/FqmhiAftreh9UCgJ6';
		Update updated;
        
        UnitTriggerHandler.GeoCoordinatesExtractor(
            new List<Unit__c>{updated}, 
            new Map<Id, Unit__c>{unit.Id => unit}
        );
        Test.stopTest();

        // Query and assert updated lat/lon values
        Unit__c finalUnit = [SELECT Id, Unit_Location__Latitude__s, Unit_Location__Longitude__s FROM Unit__c WHERE Id = :unit.Id];
        System.assertEquals(12.8629364, finalUnit.Unit_Location__Latitude__s);
        System.assertEquals(80.0759706, finalUnit.Unit_Location__Longitude__s);
    }
}