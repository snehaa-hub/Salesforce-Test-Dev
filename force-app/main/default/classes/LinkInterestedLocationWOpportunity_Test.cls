@isTest
public class LinkInterestedLocationWOpportunity_Test {
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
            enquiry.Status__c='New';
            enquiry.Mobile__c='7894561234';
            insert enquiry;
            

            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            );
            insert opp;
            
            Interested_Locations__c intLoc = new Interested_Locations__c();
            intLoc.Name = 'Interested_Locations__c';
            intLoc.Related_Enquiry__c = enquiry.Id;
            intLoc.Interested_Location_Range__c = 25;
            insert intLoc;
            
            List<LinkInterestedLocationWithOpportunity.Request> reqList = new List<LinkInterestedLocationWithOpportunity.Request>();
            LinkInterestedLocationWithOpportunity.Request req = new LinkInterestedLocationWithOpportunity.Request();
            req.enquiryId = enquiry.Id;
            req.opportunityId = opp.Id;
            reqList.add(req);
            
            Test.startTest();
            LinkInterestedLocationWithOpportunity.execute(reqList);
            Test.stopTest();
        }
    }
}