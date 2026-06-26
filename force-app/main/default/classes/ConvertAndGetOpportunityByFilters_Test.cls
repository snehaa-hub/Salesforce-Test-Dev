@isTest
public class ConvertAndGetOpportunityByFilters_Test {
 
    @isTest
    static void testExecute() {
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
            Project__c testproj = new Project__c();
            testproj.Name = 'Demo Project';
            insert testproj;
            Account testAcc = new Account();
            testAcc.Name = 'Test Account';
            insert testAcc;
 
            ConvertAndGetOpportunityByFilters.Request request = new ConvertAndGetOpportunityByFilters.Request();
            request.projectId = testproj.Id;
            request.accountId = testAcc.Id;
            request.stageList = new List<String>{'Stage1', 'Stage2'};
 
            List<ConvertAndGetOpportunityByFilters.Request> requestList = new List<ConvertAndGetOpportunityByFilters.Request>();
            requestList.add(request);
 
            List<ConvertAndGetOpportunityByFilters.Response> responseList = ConvertAndGetOpportunityByFilters.execute(requestList);
            Assert.isNotNull(responseList, 'not null');
        }
    }
}