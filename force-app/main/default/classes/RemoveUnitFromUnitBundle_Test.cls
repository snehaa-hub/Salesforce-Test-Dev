@isTest
public class RemoveUnitFromUnitBundle_Test {
    @isTest
    static void reqTestMethod(){
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
            
            Unit__c unit2 = new Unit__c();
            unit2.Building_Type__c = 'RCC';
            unit2.Ceiling_Side_Height__c = 10;
            unit2.Ceiling_Side_Height_UOM__c = 'Feet';
            unit2.Ceiling_Center_Height__c = 12;
            unit2.Ceiling_Center_Height_UOM__c = 'Feet';
            unit2.Flooring_Strength_per_MT__c = '1000';
            unit2.Floor_ht_from_ground_level__c = '8';
            unit2.Floor_ht_from_ground_level_UOM__c = 'Feet';
            unit2.No_of_shutters__c = '4';
            unit2.Fire_Noc_available__c = 'Yes';
            unit2.Fire_Safety__c = 'Extinguishers';
            unit2.Power_available__c = 'Yes';
            unit2.Rent_per_uom_Price_per_uom__c = 30;
            unit2.Built_up_Area__c = 1200;
            unit2.SIDCO_SIPCOT_CAM_or_Addl_Charges__c = 200;
            unit2.SIDCO_SIPCOT_CAM_or_Addl_Charges_UOM__c = 'Feet';
            unit2.City__c = 'Zirakpur';
            unit2.Canopy_available__c = 'Yes';
            unit2.Dock_Leveller__c = 'Yes';
            unit2.Advance_Security_Deposit__c = '3000';
            unit2.EoT_Crane_Provision__c = 'Yes';
            unit2.Office_space_available__c = 'Yes';
            unit2.Escalation__c = '8%';
            unit.Size_Range__c = 'below 10000';
            insert unit2;
            
            Shortlisted_Unit__c shortListedUnit = new Shortlisted_Unit__c(
                Unit__c = unit.id
            );
            insert shortListedUnit;
            Shortlisted_Unit__c shortListedUnit2 = new Shortlisted_Unit__c(
                Unit__c = unit2.id
            );
            insert shortListedUnit2;
            
            Unit_Bundle__c unitBundle = new Unit_Bundle__c(
                Name = 'Test Unit Bundle',
               // Opportunity__c = opp.Id,
                Linked_Unit__c = JSON.serialize(new List<String>{shortListedUnit.Id})
            );
            system.debug('unitBundle.Linked_Unit__c --> '+unitBundle.Linked_Unit__c);
            insert unitBundle;
            
            List<RemoveUnitFromUnitBundle.Request> reqs = new List<RemoveUnitFromUnitBundle.Request>();
            RemoveUnitFromUnitBundle.Request req = new RemoveUnitFromUnitBundle.Request();
            req.shortUnitID = shortListedUnit2.id;
            req.unitBundleObj = unitBundle;
            reqs.add(req);
            
            Test.startTest();
            RemoveUnitFromUnitBundle.execute(reqs);
            Test.stopTest();
        }
    }
}