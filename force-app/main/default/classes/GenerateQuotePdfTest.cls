@isTest
private class GenerateQuotePdfTest {
    
    
    public class TestDocumentService implements DocumentService {
        public void GenerateQuotePdf(String OpportunityID, String Document) {
            System.debug('Mock GenerateQuotePdf called with OpportunityID: ' + OpportunityID + ', Document: ' + Document);
        }

        public void GenerateNegotiationChecklistPdf(String OpportunityID, String unitBundleId, String DocumentTittle) {}
        public void GenerateSiteVisitQuotePdf(String unitBundleId, String OpportunityID, String siteVisitId) {}
        public void GenerateSiteVisitInspectionpdf(String OpportunityID, String siteVisitId) {}
    }

    @isTest static void testExecuteMethod() {
        Type classType = Type.forName(null, 'GenerateQuotePdfTest.TestDocumentService');
        System.assertNotEquals(null, classType, 'TestDocumentService type should not be null');

       
        Opportunity__c opp = new Opportunity__c(Name = 'Test Opp');
        insert opp;

      
        GenerateQuotePdf.Request req = new GenerateQuotePdf.Request();
        req.OpportunityID = opp.Id;
        req.Document = 'Proposal Document';

        List<GenerateQuotePdf.Request> reqList = new List<GenerateQuotePdf.Request>{ req };

      
        Test.startTest();
        GenerateQuotePdf.execute(reqList);
        Test.stopTest();

        System.debug('Test completed successfully');
    }
}