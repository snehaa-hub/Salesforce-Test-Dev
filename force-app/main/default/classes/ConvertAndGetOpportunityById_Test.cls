@isTest
public class ConvertAndGetOpportunityById_Test {
    @isTest
    static void testExecuteMethod() {
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
            OpportunityWrapper oppWrap = new OpportunityWrapper();
            oppWrap.name = 'TestOpp';
            oppWrap.closeDate = system.today() + 7;
            oppWrap.stageName = 'In Progress'; 
            ConvertAndUpsertOpportunity.Request reqOpp = new ConvertAndUpsertOpportunity.Request();
            reqOpp.opportunityWrap = oppWrap;
            List<ConvertAndUpsertOpportunity.Response> responseList = new List<ConvertAndUpsertOpportunity.Response>();
            responseList = ConvertAndUpsertOpportunity.execute(new List<ConvertAndUpsertOpportunity.Request>{reqOpp});
 
            ConvertAndGetOpportunityById.Request testRequest = new ConvertAndGetOpportunityById.Request();
            testRequest.opportunityId = responseList[0].recordId;
 
            List<ConvertAndGetOpportunityById.Request> requestList = new List<ConvertAndGetOpportunityById.Request>();
            requestList.add(testRequest);
 
            Test.startTest();
            List<ConvertAndGetOpportunityById.Response> responseList1 = ConvertAndGetOpportunityById.execute(requestList);
            Test.stopTest();
 
            System.assertNotEquals(null, responseList1,'not equal');
 
            System.assertEquals(1, responseList1.size(),'equal');
 
            System.assertNotEquals(null, responseList1[0].opportunityWrap,'not equal');
        }
    }
}