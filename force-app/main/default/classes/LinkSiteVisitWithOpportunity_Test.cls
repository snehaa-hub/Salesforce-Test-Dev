@isTest
public class LinkSiteVisitWithOpportunity_Test {
	@isTest
    public static void testRun(){
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
        
            Enquiry__c enquiry = new Enquiry__c();
            //enquiry.Project__c = project.Id;
            enquiry.Status__c='New';
            enquiry.Mobile__c = '7896345126';
            insert enquiry;
            
            Opportunity__c  opp = new Opportunity__c (
                Name = 'Test Opportunity',
                Stage__c = 'Qualified',
                Close_Date__c = Date.today().addDays(30)
            );
            insert opp;
            
            Site_Visit__c sv = new Site_Visit__c();
            sv.Name = 'Test Site Visit';
            sv.Status__c = 'Scheduled';
            sv.Enquiry__c = enquiry.Id;
            //sv.Opportunity__c = opp.Id;
            insert sv;
            
            List<LinkSiteVisitWithOpportunity.Request> reqList = new List<LinkSiteVisitWithOpportunity.Request>();
            LinkSiteVisitWithOpportunity.Request req = new LinkSiteVisitWithOpportunity.Request();
            req.enquiryId = enquiry.Id;
            //req.opportunityId = opp.Id;
            reqList.add(req);
            
            Test.startTest();
            LinkSiteVisitWithOpportunity.execute(reqList);
            Test.stopTest();
        }
    }
}