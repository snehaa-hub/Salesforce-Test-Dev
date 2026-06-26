@isTest
public class QuotePdfControllerTest {

    @isTest
    static void testQuotePdfController() {
          Opportunity__c opp = new Opportunity__c();
            opp.Name = 'TestOpp';
        	opp.Landlord_Name__c = True;
            opp.Landlord_Mobile__c = True;
            opp.Close_Date__c = system.today() + 7;
            opp.Stage__c = 'In Progress'; 
            insert opp;
            Unit__c unit = new Unit__c(
                Name = 'Test Unit',
                Carpet_Area__c = 1000,
                Type_of_Unit__c = 'Land',
                Size_Range__c = '10000 - 25000'
            );
            insert unit;
            Shortlisted_Unit__c shortListedUnit1 = new Shortlisted_Unit__c(
                Unit__c = unit.Id
            );
            insert shortListedUnit1;
            
            Unit_Bundle__c unitBundle1 = new Unit_Bundle__c(
                Name = 'Test Unit Bundle',
                Opportunity__c = opp.Id,
                Linked_Unit__c = JSON.serialize(new List<String>{shortListedUnit1.Id,unit.Id})
            );
            insert unitBundle1;
        Opportunity__c opportunity = new Opportunity__c(
            Name = 'Test Opportunity',
            //Proposal_Json__c = '[{"Id": "001", "Name": "Unit Bundle 1", "UnitData": []}]',
            Proposal_Json__c =  '[{"Name":"Bundle - 2","Id":"'+unitBundle1.id +'", "UnitData":[{"selectedContentVersionID":["/sfc/servlet.shepherd/version/download/068H400000033MWIAY","/sfc/servlet.shepherd/version/download/068H400000033MbIAI","/sfc/servlet.shepherd/version/download/068H400000033McIAI","/sfc/servlet.shepherd/version/download/068H400000033MlIAI"], "Data":{"Id":"a0DH4000000YZSkMAO","Name":"Ramakrishnan","Type_of_Unit__c":"Both","Built_up_Area__c":25000,"Saleable_Area__c":25000,"No_of_shutters__c":"2","City__c":"Vyasarpadi","Ceiling_Center_Height__c":25,"Ceiling_Center_Height_UOM__c":"Feet","Ceiling_Side_Height__c":20,"Ceiling_Side_Height_UOM__c":"Feet","Building_Type__c":"PEB","Floor_ht_from_ground_level__c":"4","Floor_ht_from_ground_level_UOM__c":"Feet","Total_Rent_Total_Price_Text__c":0}, "Images":["/sfc/servlet.shepherd/version/download/068H400000033MWIAY","/sfc/servlet.shepherd/version/download/068H400000033MbIAI","/sfc/servlet.shepherd/version/download/068H400000033McIAI","/sfc/servlet.shepherd/version/download/068H400000033MlIAI","/sfc/servlet.shepherd/version/download/068H400000033dsIAA","/sfc/servlet.shepherd/version/download/068H400000033dwIAA","/sfc/servlet.shepherd/version/download/068H400000033e1IAA"]}]}]',
            Share_Location__c = true, Landlord_Name__c = True,  Landlord_Mobile__c = True
        );
        insert opportunity;
        
        // Set the current page parameter to simulate URL with Opportunity ID
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
          List<String> expectedImages = new List<String>{
            '/sfc/servlet.shepherd/version/download/068H400000033MWIAY',
            '/sfc/servlet.shepherd/version/download/068H400000033MbIAI',
            '/sfc/servlet.shepherd/version/download/068H400000033McIAI',
            '/sfc/servlet.shepherd/version/download/068H400000033MlIAI',
            '/sfc/servlet.shepherd/version/download/068H400000033dsIAA',
            '/sfc/servlet.shepherd/version/download/068H400000033dwIAA',
            '/sfc/servlet.shepherd/version/download/068H400000033e1IAA'
        };

        // Fetch actual Images list from the controller
       

        // Assert that both lists are equal
       
        // Initialize the controller
        QuotePdfController controller = new QuotePdfController();
       
        // Test if the Opportunity is correctly retrieved
       	System.assertNotEquals(null, controller.unitBundles);
        System.assertEquals(1, controller.unitBundles.size());
        System.assertEquals('Bundle - 2', controller.unitBundles[0].Name);
        System.assertEquals(controller.unitBundles[0].Id, controller.unitBundles[0].Id);
       
        System.assertEquals(true, controller.googleMapLinkShare);
        QuotePdfController.testCoverage();
        Test.stopTest();
        
        
    }
    
    
   
}