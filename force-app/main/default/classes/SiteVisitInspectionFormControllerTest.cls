@isTest
public class SiteVisitInspectionFormControllerTest {
    @isTest
    static void testSiteVisitInspectionFormController() {
        // Create a test profile for the user
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        // Create a test user
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser+' + System.currentTimeMillis() + '@gmail.com',
            Username = 'testuser+' + System.currentTimeMillis() + '@example.com',
            CommunityNickname = 'testuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = pf.Id
        );
        INSERT u;

        // Assign a permission set to the test user
        PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission' LIMIT 1];
        if (newPermission != null) {
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = u.Id,
                PermissionSetId = newPermission.Id
            );
            INSERT psa;
        }

        // Run test logic in the context of the test user
        System.runAs(u) {
            // Step 1: Create test data
            List<SiteVisitInspectionFormController.Wrapper> wrapperList = new List<SiteVisitInspectionFormController.Wrapper>();
            for (Integer i = 1; i <= 3; i++) {
                SiteVisitInspectionFormController.Wrapper wrapper = new SiteVisitInspectionFormController.Wrapper();
                wrapper.Name = 'Field ' + i;
                wrapper.Value = 'Value ' + i;
                wrapper.SequenceNo = String.valueOf(i);
                wrapper.Datatype = 'String';
                wrapperList.add(wrapper);
            }

            // Serialize the wrapper list into JSON format
            String jsonChecklist = JSON.serialize(wrapperList);

            // Create a test Site_Visit__c record
            Site_Visit__c siteVisit = new Site_Visit__c(
                Name = 'Test Site Visit',
                Site_Visit_Inspection_Checklist__c = jsonChecklist
            );
            INSERT siteVisit;

            // Step 2: Set the page reference and parameters
            Test.setCurrentPageReference(Page.SiteVisitInspectionChecklistPdf); // Ensure the page name is correct
            ApexPages.currentPage().getParameters().put('Id', siteVisit.Id);

            // Step 3: Instantiate the controller and validate wrapper list
            Test.startTest();
            SiteVisitInspectionFormController controller = new SiteVisitInspectionFormController();

            for (Integer i = 0; i < controller.wrapList.size(); i++) {
                SiteVisitInspectionFormController.Wrapper expected = wrapperList[i];
                SiteVisitInspectionFormController.Wrapper actual = controller.wrapList[i];
                System.assertEquals(expected.Name, actual.Name, 'Wrapper Name does not match');
                System.assertEquals(expected.Value, actual.Value, 'Wrapper Value does not match');
                System.assertEquals(expected.SequenceNo, actual.SequenceNo, 'Wrapper SequenceNo does not match');
                System.assertEquals(expected.Datatype, actual.Datatype, 'Wrapper Datatype does not match');
            }
            Test.stopTest();
        }
    }
}