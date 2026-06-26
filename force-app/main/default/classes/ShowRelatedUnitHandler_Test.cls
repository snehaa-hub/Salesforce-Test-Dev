@isTest
public class ShowRelatedUnitHandler_Test {

    @isTest
    public static void testGetUnits() {
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

            Map<String, Object> unitBundleMap = new Map<String, Object>();
            unitBundleMap.put('Name','Test Bundle');
            unitBundleMap.put('Opportunity__c',responseList[0].recordId);

            Unit_Bundle__c unitBundle = (Unit_Bundle__c) JSON.deserialize(
                JSON.serialize(unitBundleMap), 
                Unit_Bundle__c.class
            );

            insert unitBundle;
           
            
            Unit__c testUnit = new Unit__c();
            //testUnit.Name = 'Test Unit';
            testunit.Size_Range__c = 'below 10000';
            insert testUnit;

            Map<String, Object> shortlistedUnitMap = new Map<String, Object>();
            shortlistedUnitMap.put('Unit__c',testUnit.Id);
            shortlistedUnitMap.put('Opportunity__c',responseList[0].recordId);

            Shortlisted_Unit__c shortlistedUnit = (Shortlisted_Unit__c) JSON.deserialize(
                JSON.serialize(shortlistedUnitMap), 
                Shortlisted_Unit__c.class
            );

            insert shortlistedUnit;

            List<String> shortlistedUnitIds = new List<String>{ shortlistedUnit.Id };
            unitBundle.Linked_Unit__c = JSON.serialize(shortlistedUnitIds);
            update unitBundle;

            String baseURL = 'https://example.com'; // Provide a suitable base URL
            String result = ShowRelatedUnitHandler.getUnits(unitBundle.Id, baseURL);
            Assert.isNotNull( result, 'String should not be null');
        }
    }
}