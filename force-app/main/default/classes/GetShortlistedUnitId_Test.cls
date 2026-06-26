@isTest
public class GetShortlistedUnitId_Test {
	@isTest
    public static void testRun(){
        
        Opportunity__c opp = new Opportunity__c();
        //opp.Account_Name__c = personAcct.id;
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
        
        Shortlisted_Unit__c shortListedUnit = new Shortlisted_Unit__c(
            Unit__c = unit.id,
            Opportunity__c = opp.Id
        );
        insert shortListedUnit;
		
        Unit_Bundle__c unitBundle = new Unit_Bundle__c(
            Name = 'Test Unit Bundle',
           // Opportunity__c = opp.Id,
            Linked_Unit__c = JSON.serialize(new List<String>{shortListedUnit.Id})
        );
        insert unitBundle;
            
        List<GetShortlistedUnitId.Request> requestList = new List<GetShortlistedUnitId.Request>();
        GetShortlistedUnitId.Request testRequest = new GetShortlistedUnitId.Request();
        testRequest.unitId = unit.Id;
        testRequest.OpportunityID = opp.Id;

        requestList.add(testRequest);
        
        Test.startTest();
        GetShortlistedUnitId.execute(requestList);
        Test.stopTest();
    }
}