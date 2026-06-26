@isTest
public class UpsertRecordWithOpportunity_Test {

    @isTest
    static void testUpsertRecordWithOpportunity() {
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
            
            Site_Visit__c siteVisit = new Site_Visit__c(Name = 'Test Site Visit');
            
            UpsertRecordWithOpportunity.Request request = new UpsertRecordWithOpportunity.Request();
            request.record = siteVisit;
            request.opportunityId = responseList[0].recordId;
            request.fieldApiName = 'Opportunity__c';

            List<UpsertRecordWithOpportunity.Request> requestList = new List<UpsertRecordWithOpportunity.Request>();
            requestList.add(request);

            Test.startTest();
            UpsertRecordWithOpportunity.execute(requestList);

            List<Site_Visit__c> siteVisitList = [SELECT Id FROM Site_Visit__c];
            Assert.isNotNull( siteVisitList, 'List should not be null');
            Test.stopTest();
        }
    }
}