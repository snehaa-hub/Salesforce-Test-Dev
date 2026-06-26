@isTest
public class ShortListBundleMessageControllerTest {
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
        system.runAs(u){
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
            
            Opportunity__c  opp = new Opportunity__c (
                Name = 'Test Opportunity',
                Stage__c = 'In Progress',
                Close_Date__c = Date.today().addDays(30),
                Account_Name__c = accountObject.Id
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
            unit.Size_Range__c = 'below 10000';
            insert unit;
            
            Shortlisted_Unit__c shortListedUnit = new Shortlisted_Unit__c(
                Unit__c = unit.id,
                Opportunity__c = opp.Id
            );
            insert shortListedUnit;
            
            Unit_Bundle__c unitBundle = new Unit_Bundle__c(
                Name = 'Test Unit Bundle',
                Opportunity__c = opp.Id,
                Linked_Unit__c = JSON.serialize(new List<String>{shortListedUnit.Id})
            );
            insert unitBundle;
            
            PageReference pageRef = new PageReference('/apex/SiteVisitInputPage');
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', unitBundle.Id);
            
            ApexPages.StandardController standardController = new ApexPages.StandardController(unitBundle);
            ShortListBundleMessageController controller = new ShortListBundleMessageController(standardController);
            controller.siteVisitDate = system.now().addDays(5);

            Test.startTest();
            controller.updateUnitBundleStatus();
            Test.stopTest();
        }
    }
}