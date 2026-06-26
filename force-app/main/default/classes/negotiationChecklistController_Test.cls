@isTest
public class negotiationChecklistController_Test {
	@isTest
    static void testNegotiationChecklistController() {
        Id personAccRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id;
        Id tenantRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'Enquiry__c' AND DeveloperName = 'Tenant' LIMIT 1].Id;

        // Create Accounts
        Account tenantAcc = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            RecordTypeId = personAccRtId
        );
        insert tenantAcc;

        Account landlordAcc = new Account(Name = 'Landlord Inc');
        insert landlordAcc;

        // Create Enquiry (Tenant)
        Enquiry__c enquiry = new Enquiry__c(
            Name = 'Test Enquiry',
            Contact_Person__c = tenantAcc.Id,
            RecordTypeId = tenantRtId,
            Mobile__c = '1234567890'
        );
        insert enquiry;

        // Create Opportunity
        Opportunity__c opp = new Opportunity__c(
            Name = 'Test Opp',
            Enquiry__c = enquiry.Id,
            Account_Name__c = tenantAcc.Id
        );
        insert opp;

        // Create Unit
        Unit__c unit = new Unit__c(
            Name = 'Test Unit',
            Point_of_Contact__c = landlordAcc.Id,
            Size_Range__c = 'below 10000'
        );
        insert unit;

        // Create Shortlisted Unit
        Shortlisted_Unit__c shortlisted = new Shortlisted_Unit__c(
            Opportunity__c = opp.Id,
            Unit__c = unit.Id
        );
        insert shortlisted;

        // Prepare JSON array as String
        List<String> shortlistedIds = new List<String>{shortlisted.Id};
        String jsonArray = JSON.serialize(shortlistedIds);

        // Prepare Negotiation Checklist JSON
        List<negotiationChecklistController.Wrapper> testList = new List<negotiationChecklistController.Wrapper>();
        negotiationChecklistController.Wrapper wrap = new negotiationChecklistController.Wrapper();
        wrap.Name = 'Test Item';
        wrap.Value = 'Yes';
        wrap.SequenceNo = '1';
        wrap.IsMainHeading = 'false';
        wrap.IsSubLabel = 'true';
        wrap.DefaultValue = 'Hello';
        wrap.AdditionalValue = 'Hello';
        wrap.IsHeading = 'true';
        wrap.colSpan = 1;
        wrap.colSpan2 = 2;
        wrap.sequenceVisible = 'true';
        wrap.AdditionalVisible = 'false';
        wrap.Disclaimer = 'true';
        wrap.Location = 'true';
        testList.add(wrap);

        String jsonData = JSON.serialize(testList);

        // Create Unit Bundle
        Unit_Bundle__c bundle = new Unit_Bundle__c(
            Name = 'Test Bundle',
            Opportunity__c = opp.Id,
            Negotiation_Checklist__c = jsonData,
            Linked_Unit__c = jsonArray
        );
        insert bundle;

        // Set URL parameters
        Test.startTest();
        ApexPages.currentPage().getParameters().put('unitBundleId', bundle.Id);
        ApexPages.currentPage().getParameters().put('opportunityId', opp.Id);

        // Instantiate the controller
        negotiationChecklistController controller = new negotiationChecklistController();

        System.assertNotEquals(null, controller.wrapList);
        System.assertEquals('ALLWarehouses', controller.brokerName);
        System.assertEquals(tenantAcc.FirstName + ' ' + tenantAcc.LastName, controller.tenantName);
        System.assertEquals(landlordAcc.Name, controller.landlordName);
        Test.stopTest();
    }
    /*@isTest
    static void testNegotiationChecklistController() {
        Id personAccRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id;
        Id tenantRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'Enquiry__c' AND DeveloperName = 'Tenant' LIMIT 1].Id;
        Id brokerRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'Enquiry__c' AND DeveloperName = 'Broker' LIMIT 1].Id;

        // 2. Create Accounts
        Account tenantAcc = new Account(
            FirstName = 'John',
            LastName = 'Doe',
            RecordTypeId = personAccRtId
        );
        insert tenantAcc;

        Account brokerAcc = new Account(Name = 'Broker LLC');
        insert brokerAcc;

        Account landlordAcc = new Account(Name = 'Landlord Inc');
        insert landlordAcc;

        // 3. Create Enquiry (Tenant)
        Enquiry__c enquiry = new Enquiry__c(
            Name = 'Test Enquiry',
            Contact_Person__c = tenantAcc.Id,
            RecordTypeId = tenantRtId,
            Mobile__c = '1234567890'
        );
        insert enquiry;

        // 4. Create Opportunity
        Opportunity__c opp = new Opportunity__c(
            Name = 'Test Opp',
            Enquiry__c = enquiry.Id,
            Account_Name__c = tenantAcc.Id
        );
        insert opp;

        // 5. Create Unit
        Unit__c unit = new Unit__c(
            Name = 'Test Unit',
            Point_of_Contact__c = landlordAcc.Id
        );
        insert unit;

        // 6. Create Shortlisted Unit
        Shortlisted_Unit__c shortlisted = new Shortlisted_Unit__c(
            Opportunity__c = opp.Id,
            Unit__c = unit.Id
        );
        insert shortlisted;

        // 7. Create JSON for Negotiation_Checklist__c
        List<negotiationChecklistController.Wrapper> testList = new List<negotiationChecklistController.Wrapper>();
        negotiationChecklistController.Wrapper wrap = new negotiationChecklistController.Wrapper();
        wrap.Name = 'Test Item';
        wrap.Value = 'Yes';
        wrap.SequenceNo = '1';
        wrap.IsMainHeading = 'false';
        wrap.IsSubLabel = 'true';
        wrap.DefaultValue = 'Hello';
        wrap.AdditionalValue = 'Hello';
        wrap.IsHeading = 'true';
        wrap.colSpan = 1;
        wrap.colSpan2 = 2;
        wrap.sequenceVisible = 'true';
        wrap.AdditionalVisible = 'false';
       	wrap.Disclaimer = 'true';
        wrap.Location = 'true';
        testList.add(wrap);

        String jsonData = JSON.serialize(testList);

        // 8. Create Unit Bundle with JSON string
        Unit_Bundle__c bundle = new Unit_Bundle__c(
            Name = 'Test Bundle',
            Opportunity__c = opp.Id,
            Negotiation_Checklist__c = jsonData
        );
        insert bundle;

        // 9. Set URL parameters
        Test.startTest();
        ApexPages.currentPage().getParameters().put('unitBundleId', bundle.Id);
        ApexPages.currentPage().getParameters().put('opportunityId', opp.Id);

        // 10. Instantiate the controller
        negotiationChecklistController controller = new negotiationChecklistController();

        System.assertNotEquals(null, controller.wrapList);
        System.assertEquals('ALLWarehouses', controller.brokerName);
        System.assertEquals(tenantAcc.FirstName + ' ' + tenantAcc.LastName, controller.tenantName);
        System.assertEquals(landlordAcc.Name, controller.landlordName);
        Test.stopTest();
    }

    @isTest
    public static void testRun(){
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
        
        RecordType tenantRt = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'Enquiry__c' AND DeveloperName = 'Tenant' 
            LIMIT 1
		];
        RecordType brokerRt = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'Enquiry__c' AND DeveloperName = 'Broker' 
            LIMIT 1
		];
        system.runAs(u){
            RecordType personRt = [
                SELECT Id FROM RecordType 
                WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount'
                LIMIT 1
            ];
            Account acc=new Account(Name='Test',
                                    RecordTypeId = personRt.Id
                                   );
            insert acc;
            Enquiry__c tenEnq=new Enquiry__c(
            	Name ='Test',
                Email__c = 'noreply@gmail.com',
                Mobile__c = '1458965258',
                Contact_Person__c = acc.Id,
                RecordTypeId = tenantRt.Id
            	);
            insert tenEnq;
            Enquiry__c tenEnq1=new Enquiry__c(
            	Name ='Test Opportunity1',
                Email__c = 'noreply22@gmail.com',
                Mobile__c = '1458965258',
                Contact_Person__c = acc.Id,
                RecordTypeId = brokerRt.Id
            	);
            insert tenEnq1;
            Opportunity__c opp = new Opportunity__c(
                Name = 'Test Opportunity'
            );
            insert opp;
            
            Unit__c unit = new Unit__c();
            unit.Building_Type__c = 'RCC';
            unit.Ceiling_Side_Height__c = 10;
            unit.Ceiling_Side_Height_UOM__c = 'Feet';
            unit.Ceiling_Center_Height__c = 12;
            unit.Ceiling_Center_Height_UOM__c = 'Feet';
            unit.Flooring_Strength_per_MT__c = '1000';
            unit.Floor_ht_from_ground_level__c = '8';
            unit.Floor_ht_from_ground_level_UOM__c = 'Feet';
            unit.No_of_shutters__c = '4';
            unit.Fire_Noc_available__c = 'Yes';
            unit.Fire_Safety__c = 'Extinguishers';
            unit.Power_available__c = 'Yes';
            unit.Rent_per_uom_Price_per_uom__c = 30;
            unit.Built_up_Area__c = 1200;
            unit.SIDCO_SIPCOT_CAM_or_Addl_Charges__c = 200;
            unit.SIDCO_SIPCOT_CAM_or_Addl_Charges_UOM__c = 'Feet';
            unit.City__c = 'Zirakpur';
            unit.Canopy_available__c = 'Yes';
            unit.Dock_Leveller__c = 'Yes';
            unit.Advance_Security_Deposit__c = '3000';
            unit.EoT_Crane_Provision__c = 'Yes';
            unit.Office_space_available__c = 'Yes';
            unit.Escalation__c = '8%';
            insert unit;
            
            Shortlisted_Unit__c shortListedUnit = new Shortlisted_Unit__c(
                Unit__c = unit.id,
				Opportunity__c = opp.Id
            );
            insert shortListedUnit;
            
            String Name = 'Test Negotiation_Checklist__c';
            String Value = 'qwerty';
            Integer SequenceNo = 2;
            String DefaultValue = 'abcd';
			
            String checklistJSON = JSON.serialize(new List<Object>{
    new Map<String, Object>{
        'Name' => Name,
        'Value' => Value,
        'SequenceNo' => SequenceNo,
        'DefaultValue' => DefaultValue,
        'AdditionalValue' => 'Test',
        'IsMainHeading' => 'true',
        'IsHeading' => 'true',
        'IsSubLabel' => 'true',
        'colSpan' => 2,
        'colSpan2' => 3,
        'sequenceVisible' => 'true',
        'AdditionalVisible' => 'true'
    },
    new Map<String, Object>{
        'Name' => 'Checklist 2',
        'Value' => 'val2',
        'SequenceNo' => 3,
        'DefaultValue' => 'def2',
        'AdditionalValue' => 'Extra',
        'IsMainHeading' => 'false',
        'IsHeading' => 'false',
        'IsSubLabel' => 'true',
        'colSpan' => 1,
        'colSpan2' => 1,
        'sequenceVisible' => 'false',
        'AdditionalVisible' => 'false'
    }
});

            Unit_Bundle__c unitBundle = new Unit_Bundle__c(
                Name = 'Test Unit Bundle',
               // Opportunity__c = opp.Id,
                Linked_Unit__c = JSON.serialize(new List<String>{shortListedUnit.Id}),
                Negotiation_Checklist__c = checklistJSON 				//'[{"Name":"'+Name+'","Value":"'+Value+'","SequenceNo":'+SequenceNo+',"DefaultValue":"'+DefaultValue+'","AdditionalValue":"Test","IsMainHeading":true,"IsHeading":"true", "IsSubLabel":"true", "colSpan":2, "colSpan2":3,"sequenceVisible":"true", "AdditionalVisible":"true"}]'
            );
            insert unitBundle;
            
            Test.startTest();
            ApexPages.CurrentPage().getParameters().put('unitBundleId',unitBundle.Id);
            ApexPages.CurrentPage().getParameters().put('opportunityId', opp.Id);
            negotiationChecklistController controller = new negotiationChecklistController();
            list<negotiationChecklistController.Wrapper> wrapList = controller.wrapList;
            System.assertNotEquals(null, wrapList, 'wrapList should not be null');
		System.assert(wrapList.size() > 0, 'wrapList should contain elements');
		System.assertEquals('Test Negotiation_Checklist__c', wrapList[0].Name);
		System.assertEquals('qwerty', wrapList[0].Value);
		System.assertEquals('abcd', wrapList[0].DefaultValue);
        System.assertEquals('2', wrapList[0].SequenceNo);
		System.assertEquals('Test', wrapList[0].AdditionalValue);
		System.assertEquals('true', wrapList[0].IsMainHeading);
        System.assertEquals('true', wrapList[0].IsHeading);
		System.assertEquals('true', wrapList[0].IsSubLabel);
		System.assertEquals(2, wrapList[0].colSpan);
        System.assertEquals(3, wrapList[0].colSpan2);
		System.assertEquals('true', wrapList[0].sequenceVisible);
		System.assertEquals('true', wrapList[0].AdditionalVisible);
        System.assertEquals('Border : none !important', wrapList[0].style);
        System.assertEquals('', wrapList[1].style);
}
            Test.stopTest();
        
    }*/
    }