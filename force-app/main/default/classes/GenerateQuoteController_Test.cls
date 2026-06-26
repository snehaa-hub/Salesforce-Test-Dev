@isTest
private class GenerateQuoteController_Test {
 
    @isTest
    static void testGetUnitBundleRecord() {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        User u = new User();
        u.FirstName = 'test';
        u.LastName = 'test';
        u.Alias = 'ttest';
        u.Email = 'test@gmail.com';
        u.Username = 'test@gmail.com.stylam202204';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = pf.Id;
        INSERT u;
        PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = newPermission.Id;
        INSERT psa;
 
        system.runAs(u){
           /* Opportunity__c opp = new Opportunity__c();
            opp.Name = 'TestOpp';
            opp.Close_Date__c = system.today() + 7;
            opp.Stage__c = 'In Progress'; 
            insert opp;
 
            Unit__c unit = new Unit__c(
                Name = 'Test Unit',
                Carpet_Area__c = 1000,
                Type_of_Unit__c = 'BTS'
            );
            insert unit;
            Unit__c unit1 = new Unit__c(
                Name = 'Test Unit',
                Carpet_Area__c = 1000,
                Type_of_Unit__c = 'Land'
            );
            insert unit1;
 
            Shortlisted_Unit__c shortListedUnit = new Shortlisted_Unit__c(
                Unit__c = unit.id
            );
            insert shortListedUnit;
 
			 Shortlisted_Unit__c shortListedUnit1 = new Shortlisted_Unit__c(
                Unit__c = unit1.id
            );
            insert shortListedUnit1;
 
            
            Unit_Bundle__c unitBundle = new Unit_Bundle__c(
                Name = 'Test Unit Bundle',
                Opportunity__c = opp.Id,
                Linked_Unit__c = JSON.serialize(new List<String>{unit1.Id})
            );
            insert unitBundle;*/
            RecordType rc = [SELECT Id, Name, DeveloperName, SObjectType 
FROM RecordType 
WHERE SObjectType = 'Account' 
AND DeveloperName = 'PersonAccount'];
		 Account acc = new Account(LastName='Test Name',RecordTypeId = rc.Id);
        insert acc;
	Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Enquiry__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }
            // Create Enquiry__c with the RecordType
    Enquiry__c enquiry = new Enquiry__c(
        Name = 'Test Enquiry',
        RecordTypeId = rtMap.get('Landlord'),
        Status__c = 'New', 
    	Email__c = 'test@example.com',
        Contact_Person__c = acc.Id,
        Mobile__c='1234567890',
        Size_in_sqft__c = '10000 - 25000',
        Size_in_sqfts__c = 10000
    );
    insert enquiry;

    // Create Opportunity__c
    Opportunity__c opp = new Opportunity__c(
        Name = 'Test Opportunity',
        Property_Type__c = 'Leasing',
        Account_Name__c = acc.Id,
        Enquiry__c = enquiry.Id,
        Share_Location__c = true,
        Landlord_Name__c = true,
        Landlord_Mobile__c = true,
        Size_in_sqft__c = '10000 - 25000',
        Size_in_sqfts__c = 10000
    );
    insert opp;
        Unit__c unit = new Unit__c(
            Name = 'Test BTS Unit',
            Type_of_Unit__c = 'BTS',
			Size_Range__c = '10000 - 25000',
            AW_Land_FMB_Sketch__c = 'TestSketch',
 			AW_Land_360_video__c = 'www.google.com',
            AW_Land_Road_width__c = 'Normal',
            AW_Land_Type_of_Land__c=  'Dry',
            AW_Land_Neighbour_Companies__c= 'Empty',
            AW_BTS_Location__c = 'www.google.com',
            AW_BTS_Built_up_Area__c = 222,
            AW_BTS_UOM__c = 'Cents',
             AW_BTS_Extent__c  = 'Extents',
            AW_BTS_Google_Coordinates__c = 'www.google.com',
            AW_BTS_Approval_through__c = 'CMDA',
			Approval_Available__c = 'Yes',
            AW_BTS_360_video__c = 'www.google.com'
        );
        insert unit;
	String Name = 'Test Negotiation_Checklist__c';
            String Value = 'qwerty';
            Integer SequenceNo = 2;
            String DefaultValue = 'abcd';
	 // Create Shortlisted_Unit__c
        Shortlisted_Unit__c  shortunit = new Shortlisted_Unit__c(

            Opportunity__c = opp.Id,
            Unit__c = unit.Id
        );
        insert shortunit;
    // Create Unit_Bundle__c
    Unit_Bundle__c bundle = new Unit_Bundle__c(
        Name = 'Test Bundle',
        Opportunity__c = opp.Id,
       	Linked_Unit__c = JSON.serialize(new List<String>{shortunit.Id})
    );
    insert bundle;
      
           
           
             // Create ContentVersion records
       List<ContentVersion> contentVersions = new List<ContentVersion>();

        contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
            PathOnClient = 'ExternalImage.jpg',
            Title = 'ExternalImage',
            VersionData = Blob.valueOf('External Images Data'),
            FirstPublishLocationId = unit.Id,
            Document_Type__c = 'External Images'
        ));
            contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
            PathOnClient = 'ExternalImage.jpg',
            Title = 'ExternalImage1',
            VersionData = Blob.valueOf('External Images Data'),
            FirstPublishLocationId = unit.Id,
            Document_Type__c = 'External Images'
        ));

        contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
            PathOnClient = 'InternalImage.jpg',
            Title = 'InternalImage',
            VersionData = Blob.valueOf('Internal Images Data'),
            FirstPublishLocationId = unit.Id,
            Document_Type__c = 'Internal Images'
        ));

        contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
            PathOnClient = 'CaptureImage.jpg',
            Title = 'CaptureImage',
            VersionData = Blob.valueOf('Capture Image Data'),
            FirstPublishLocationId = unit.Id,
            Document_Type__c = 'Capture Images'
        ));

        contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
            PathOnClient = 'SiteImage.jpg',
            Title = 'SiteImage',
            VersionData = Blob.valueOf('Site Plan Upload'),
            FirstPublishLocationId = unit.Id,
            Document_Type__c = 'Site Plan Upload'
        ));

        insert contentVersions;

        // Step 3: Get related ContentDocument IDs
        List<ContentVersion> insertedVersions = [
            SELECT Id, ContentDocumentId, Title 
            FROM ContentVersion 
            WHERE Id IN :contentVersions
        ];

        List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
        for (ContentVersion cv : insertedVersions) {
            contentLinks.add(new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId = opp.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ));
        }
        insert contentLinks;
		  
        // Step 4: Run the method
        Test.startTest();
        List<Map<String, Object>> result = GenerateQuoteController.getUnitBundleRecord(opp.Id);
        Test.stopTest();

        // Step 5: Assert
        System.assertNotEquals(0, result.size(), 'Expected result from getUnitBundleRecord');
        System.debug('Result: ' + result);
       
        }
    }


    

   @isTest
    static void testGetSelectedUnit() {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        User u = new User();
        u.FirstName = 'test';
        u.LastName = 'test';
        u.Alias = 'ttest';
        u.Email = 'test@gmail.com';
        u.Username = 'test@gmail.com.stylam202204';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = pf.Id;
        INSERT u;
        PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = newPermission.Id;
        INSERT psa;
        system.runAs(u){
 
            Opportunity__c opp = new Opportunity__c();
            opp.Name = 'TestOpp';
            opp.Close_Date__c = system.today() + 7;
            opp.Stage__c = 'In Progress';
            opp.Size_in_sqft__c = '10000 - 25000';
            opp.Size_in_sqfts__c = 10000;
            insert opp;

            Unit__c unit = new Unit__c(
                Name = 'Test Unit',
                Carpet_Area__c = 1000,
                Type_of_Unit__c = 'Land',
                Size_Range__c = '10000 - 25000'
            );
            insert unit;

            Unit__c unit2 = new Unit__c(
                Name = 'Test Unit2',
                Carpet_Area__c = 5000,
                Type_of_Unit__c = 'BTS',
				Size_Range__c = '10000 - 25000'
            );
            insert unit2;

            Shortlisted_Unit__c shortListedUnit = new Shortlisted_Unit__c(
                Unit__c = unit.Id
            );
            insert shortListedUnit;
            Shortlisted_Unit__c shortListedUnit2 = new Shortlisted_Unit__c(
                Unit__c = unit2.Id
            );
            insert shortListedUnit2;
            Unit_Bundle__c unitBundle = new Unit_Bundle__c(
                Name = 'Test Unit Bundle',
                Opportunity__c = opp.Id,
                Linked_Unit__c = JSON.serialize(new List<String>{shortListedUnit.Id})
            );
            insert unitBundle;

            Site_Visit__c sv = new Site_Visit__c();
            sv.Name = 'Test Site Visit';
            sv.Status__c = 'Completed';
            sv.Opportunity__c = opp.Id;
            sv.Unit_Bundle__c = unitBundle.Id;
            insert sv;
              List<ContentVersion> contentVersions = new List<ContentVersion>();

        contentVersions.add(new ContentVersion(
              ContentLocation = 'S',
           	  PathOnClient = 'ExternalImage.jpg',
              Title = 'ExternalImage',
              VersionData =  Blob.valueOf('External Images Data'),
              FirstPublishLocationId = unit.Id,
              Document_Type__c = 'External Images'
        ));
             contentVersions.add(new ContentVersion(
              ContentLocation = 'S',
           	  PathOnClient = 'ExternalImage.jpg',
              Title = 'ExternalImage',
              VersionData =  Blob.valueOf('External Images Data'),
              FirstPublishLocationId = unit.Id,
              Document_Type__c = 'External Images'
        ));

        contentVersions.add(new ContentVersion(
              ContentLocation = 'S',
           	  PathOnClient = 'InternalImage.jpg',
              Title = 'InternalImage',
              VersionData =  Blob.valueOf('Internal Images Data'),
              FirstPublishLocationId = unit.Id,
              Document_Type__c = 'Internal Images'
        ));
            contentVersions.add(new ContentVersion(
              ContentLocation = 'S',
           	  PathOnClient = 'InternalImage.jpg',
              Title = 'InternalImage',
              VersionData =  Blob.valueOf('Internal Images Data'),
              FirstPublishLocationId = unit.Id,
              Document_Type__c = 'Internal Images'
        ));

        contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
           	  PathOnClient = 'CaptureImage.jpg',
              Title = 'CaptureImage',
              VersionData =  Blob.valueOf('Capture Image Data'),
              FirstPublishLocationId = unit.Id,
              Document_Type__c = 'Capture Images'
        ));
             contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
           	  PathOnClient = 'CaptureImage.jpg',
              Title = 'CaptureImage',
              VersionData =  Blob.valueOf('Capture Image Data'),
              FirstPublishLocationId = unit.Id,
              Document_Type__c = 'Capture Images'
        ));
            
            contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
           	  PathOnClient = 'SiteImage.jpg',
              Title = 'Site Plan Upload',
              VersionData =  Blob.valueOf('Site Plan Upload'),
              FirstPublishLocationId = unit.Id,
              Document_Type__c = 'Site Plan Upload'
        ));
            contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
           	  PathOnClient = 'SiteImage.jpg',
              Title = 'Site Plan Upload',
              VersionData =  Blob.valueOf('Site Plan Upload'),
              FirstPublishLocationId = unit.Id,
              Document_Type__c = 'Site Plan Upload'
        ));
            contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
           	  PathOnClient = 'FloorImage.jpg',
              Title = 'Floor Plan Upload',
              VersionData =  Blob.valueOf('Floor Plan Upload'),
              FirstPublishLocationId = unit.Id,
              Document_Type__c = 'Floor Plan Upload'
        ));
             contentVersions.add(new ContentVersion(
            ContentLocation = 'S',
           	  PathOnClient = 'FloorImage.jpg',
              Title = 'Floor Plan Upload',
              VersionData =  Blob.valueOf('Floor Plan Upload'),
              FirstPublishLocationId = unit.Id,
              Document_Type__c = 'Floor Plan Upload'
        ));
            
            Insert contentVersions;
            
              List<ContentDocumentLink> contentVersionList = [
            SELECT ContentDocumentId, LinkedEntityId, 
                   ContentDocument.LatestPublishedVersionId,
                   ContentDocument.LatestPublishedVersion.Document_Type__c
            FROM ContentDocumentLink
        ];
            
            
            system.debug('contentVersionList  test :'+contentVersionList);
            
 
            List<GenerateQuoteController.ShortListUnit> shortListUnits = new List<GenerateQuoteController.ShortListUnit>();
            GenerateQuoteController.ShortListUnit shortListUnit = new GenerateQuoteController.ShortListUnit();
            shortListUnit.shortListId = unitBundle.Id;
            shortListUnits.add(shortListUnit);
 
            String recordsJson = JSON.serialize(shortListUnits);
            Test.startTest();
            List<Map<String, Object>> result = GenerateQuoteController.getSelectedUnit(opp.Id, recordsJson);
            Decimal value5 = 12345.67;
            // ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :testcontentversion.Id];
            GenerateQuoteController.Test();
            
            Test.stopTest();
 
            System.debug('Result of getSelectedUnit: ' + result);
        }
    }


    @isTest
    static void testFormatNumberIndian() {
        
        // Create an instance of the class where the method is defined
        GenerateQuoteController controller = new GenerateQuoteController();
        // Test 1: Large number (e.g., 123456789)
        Decimal value1 = 123456789;
        String result1 = controller.formatNumberIndian(value1); // Calling the non-static method
        System.assertEquals('12,34,56,789', result1, 'Formatted value for 123456789 should be 12,34,56,789');
        // Test 2: Smaller number (e.g., 12345)
        Decimal value2 = 12345;
        String result2 = controller.formatNumberIndian(value2);
        System.assertEquals('12,345', result2, 'Formatted value for 12345 should be 12,345');
        // Test 3: Number with fewer than 3 digits (e.g., 12)
        Decimal value3 = 12;
        String result3 = controller.formatNumberIndian(value3);
        System.assertEquals('12', result3, 'Formatted value for 12 should be 12 (no commas needed)');
        // Test 4: Number with exactly 3 digits (e.g., 123)
        Decimal value4 = 123;
        String result4 = controller.formatNumberIndian(value4);
        System.assertEquals('123', result4, 'Formatted value for 123 should be 123 (no commas needed)');
 
        // Test 5: Test with decimal numbers (e.g., 12345.67)
        Decimal value5 = 12345.67;
        String result5 = controller.formatNumberIndian(value5);
        System.assertEquals('12,345', result5, 'Formatted value for 12345.67 should ignore decimal part and be 12,345');
 
        // Test 6: Zero value
        Decimal value6 = 0;
        String result6 = controller.formatNumberIndian(value6);
        System.assertEquals(null, result6, 'Formatted value for 0 should be null since the method only works for positive numbers');
 
        // Test 7: Negative value (should not be formatted as per logic)
        Decimal value7 = -12345;
        String result7 = controller.formatNumberIndian(value7);
        System.assertEquals(null, result7, 'Formatted value for negative numbers should be null since only positive numbers are formatted');
    }
 
}