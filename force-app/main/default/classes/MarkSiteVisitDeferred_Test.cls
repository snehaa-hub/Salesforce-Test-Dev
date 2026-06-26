@isTest
public class MarkSiteVisitDeferred_Test {
	@isTest
    public static void testRun(){
        
        Opportunity__c  opp = new Opportunity__c (
            Name = 'Test Opportunity',
            Stage__c = 'Qualified',
            Close_Date__c = Date.today().addDays(30)
        );
        insert opp;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.Name = 'Test Site Visit';
        sv.Status__c = 'Scheduled';
      //  sv.Opportunity__c = opp.Id;
        insert sv;
        
        List<MarkSiteVisitDeferred.Request> reqList = new List<MarkSiteVisitDeferred.Request>();
        MarkSiteVisitDeferred.Request req = new MarkSiteVisitDeferred.Request();
        req.OpportunityID = opp.Id;
        reqList.add(req);
        
        Test.startTest();
        MarkSiteVisitDeferred.execute(reqList);
        Test.stopTest();
    }
}