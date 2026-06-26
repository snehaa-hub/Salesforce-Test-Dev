/**
* @File Name : GpsCameraImageControllerTest.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 6, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 6, 2025 |   | Initial Version
**/
@isTest
public class GpsCameraImageControllerTest {
	 @isTest
    static void testSaveImage() {
        // Step 1: Create a dummy parent record
        Unit__c testAccount = new Unit__c(Name = 'Test Account',Size_Range__c = 'below 10000');
        insert testAccount;
        Opportunity__c testOpportunity = new Opportunity__c(Name =  'Test Opportunity');
        insert testOpportunity;
        Shortlisted_Unit__c stl = new Shortlisted_Unit__c(Unit__c=testAccount.Id);
        insert stl;
        Unit_Bundle__c ub = new Unit_Bundle__c(Name ='Test Bundle', Linked_Unit__c=JSON.serialize(new List<String>{stl.Id}));
        insert ub;
        Site_Visit__c svAccount = new Site_Visit__c(Name = 'Test Account',Unit_Bundle__c=ub.Id,Opportunity__c =testOpportunity.Id );
        insert svAccount;
        
        

        // Step 2: Create a small dummy PNG base64 string (1x1 pixel transparent PNG)
        String base64Prefix = 'data:image/png;base64,';
        String dummyBase64Image = base64Prefix +
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y+RUIYAAAAASUVORK5CYII=';

        // Step 3: Call the method
        Test.startTest();
        GpsCameraImageController.saveImage(dummyBase64Image, testAccount.Id,'20.6756756,80.4565465',' ','Internal |Images');
        GpsCameraImageController.saveSiteVisitImage(dummyBase64Image, svAccount.Id);
        GpsCameraImageController.saveOpportunityImage(dummyBase64Image, svAccount.Id);
        
        Test.stopTest();
    }

	
}