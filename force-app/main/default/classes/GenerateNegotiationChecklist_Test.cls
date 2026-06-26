@isTest
public class GenerateNegotiationChecklist_Test {
	@isTest
    public static void testRun(){

        Opportunity__c opp = new Opportunity__c(
            Name = 'Test Opportunity',
            Stage__c = 'In progress',
            Close_Date__c = Date.today().addDays(30)
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
            Unit__c = unit.id
        );
        insert shortListedUnit;
		
        Unit_Bundle__c unitBundle = new Unit_Bundle__c(
            Name = 'Test Unit Bundle',
           // Opportunity__c = opp.Id,
            Linked_Unit__c = JSON.serialize(new List<String>{shortListedUnit.Id})
        );
        insert unitBundle;
        Site_Visit__c sv = new Site_Visit__c();
        sv.Name = 'Test Site Visit';
        sv.Status__c = 'Scheduled';
        sv.Opportunity__c = opp.Id;
        insert sv;

        List<GenerateNegotiationChecklist.Request> reqList = new List<GenerateNegotiationChecklist.Request>();
        GenerateNegotiationChecklist.Request req = new GenerateNegotiationChecklist.Request();
        req.unitBundleId = unitBundle.Id;
        req.OpportunityID = opp.Id;
        reqList.add(req);

        List<GenerateSiteVisitQuotePdf.Request> reqList1 = new List<GenerateSiteVisitQuotePdf.Request>();
        GenerateSiteVisitQuotePdf.Request req1 = new GenerateSiteVisitQuotePdf.Request();
        req1.unitBundleId = unitBundle.Id;
        req1.OpportunityID = opp.Id;
        req1.siteVisitId= sv.Id;
        reqList1.add(req1);

        List<GenerateQuotePdf.Request> reqList2 = new List<GenerateQuotePdf.Request>();
        GenerateQuotePdf.Request req2 = new GenerateQuotePdf.Request();
        req2.OpportunityID = opp.Id;
        reqList2.add(req2);
        
        List<GenerateSiteVisitInspectionpdf.Request> reqList4 = new List<GenerateSiteVisitInspectionpdf.Request>();
        GenerateSiteVisitInspectionpdf.Request req4 = new GenerateSiteVisitInspectionpdf.Request();
       
        req4.OpportunityID = opp.Id;
        req4.siteVisitId = sv.Id;
        reqList4.add(req4);
        
        Test.startTest();
        GenerateNegotiationChecklist.execute(reqList);
        GenerateSiteVisitQuotePdf.execute(reqList1);
        GenerateQuotePdf.execute(reqList2);
        GenerateSiteVisitInspectionpdf.execute(reqList4);
        Test.stopTest();
    }
}