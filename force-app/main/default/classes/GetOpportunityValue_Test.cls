@isTest
public class GetOpportunityValue_Test {
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

            Project__c testProject = new Project__c(Name = 'DemoProject');
            insert testProject;
            
          
            
            Unit__c testUnit = new Unit__c(Name = 'abc',Project__c = testProject.Id,Size_Range__c = 'below 10000');
            insert testUnit;
            
            Unit__c testBU = new Unit__c(Name = 'demoBU',Project__c = testProject.Id,Size_Range__c = 'below 10000');
            insert testBU;

            OpportunityWrapper oppWrap = new OpportunityWrapper();
            oppWrap.name = 'TestOpp';
            oppWrap.closeDate = system.today() + 7;
            oppWrap.stageName = 'In Progress'; 
            
            ConvertAndUpsertOpportunity.Request reqOpp = new ConvertAndUpsertOpportunity.Request();
            reqOpp.opportunityWrap = oppWrap;
            List<ConvertAndUpsertOpportunity.Response> responseList = new List<ConvertAndUpsertOpportunity.Response>();
            responseList = ConvertAndUpsertOpportunity.execute(new List<ConvertAndUpsertOpportunity.Request>{reqOpp});

            Map<String, Object> shortlistedUnitMap = new Map<String, Object>();
            shortlistedUnitMap.put('Unit__c',testUnit.Id);
            shortlistedUnitMap.put('Opportunity__c',responseList[0].recordId);

            Shortlisted_Unit__c shortlistedUnit = (Shortlisted_Unit__c) JSON.deserialize(
                JSON.serialize(shortlistedUnitMap), 
                Shortlisted_Unit__c.class
            );

            INSERT shortlistedUnit;
            
            GetOpportunityValue.Request request = new GetOpportunityValue.Request();
            request.record = shortlistedUnit;
            request.fieldApiName = 'Opportunity__c';
            
            Assert.isNotNull(GetOpportunityValue.execute(new List<GetOpportunityValue.Request>{request}), 'not null');
        }
    }
}