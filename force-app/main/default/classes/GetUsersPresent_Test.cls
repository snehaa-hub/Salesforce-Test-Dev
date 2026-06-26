@istest
public class GetUsersPresent_Test {
    public static testMethod void testGetUsersPresent() {
        Test.StartTest();
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
        system.runAs(u){
            
            CustomPermission existingCustomPermission = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName = 'Is_RM' LIMIT 1];
            
            PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = newPermission.Id;
            INSERT psa;
            
            SetupEntityAccess setEntityAcc = new SetupEntityAccess();
            setEntityAcc.ParentId = newPermission.Id;
            setEntityAcc.SetupEntityId = existingCustomPermission.Id;
            insert setEntityAcc;
            
            List<BusinessHours> bhs = [SELECT Id 
                                       FROM BusinessHours 
                                       WHERE IsDefault=true];
            
            
            GetUsersPresent.Request req = new GetUsersPresent.Request();
            req.salesOffice = bhs[0].Id;
            req.permissionName = existingCustomPermission.DeveloperName;
            
            GetUsersPresent.execute(new List<GetUsersPresent.Request> {req});
            Test.stopTest(); 
        }
    }
}