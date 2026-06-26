@isTest
public class MassDeleteExtensionTest {
    @isTest
    static void testMassDeleteSelectedEnquiries() {
        
        List<Enquiry__c> enquirylist = new List<Enquiry__c>();
        // Step 1: Create sample Enquiry__c records
        RecordType landRT = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Enquiry__c' AND Name = 'Tenant'
            LIMIT 1
        ];
        Enquiry__c enq1=new Enquiry__c(
            Name = 'Test Enquiry 1',
            Type_of_Unit__c = 'Land',
                Status__c = 'Closed',
                Reason_for_Closed__c = 'Qualified',
                 Mobile__c = '9876543210',
                RecordTypeId = landRT.Id,
            Size_in_sqfts__c = 2500,
            Size_in_sqft__c = 'below 10000'
        );
        enquirylist.add(enq1);
          RecordType rt = [SELECT Id, Name FROM RecordType 
                 WHERE DeveloperName = 'Tenant' 
                 AND SObjectType = 'Enquiry__c' 
                 LIMIT 1];
        Enquiry__c enquiry = new Enquiry__c(
            Name = 'Test Enquiry',
            Email__c = 'testuser@example.com',
            Type_of_Unit__c = 'Land', // match with unit
            Status__c ='Closed',
            Mobile__c ='1111100076',
            Reason_for_Closed__c = 'Qualified',
            RecordTypeId =rt.Id,
            Size_in_sqfts__c = 2500,
            Size_in_sqft__c = 'below 10000'
        );
        enquirylist.add(enquiry);
        insert enquirylist;

        // Step 2: Simulate selected records in StandardSetController
        Test.startTest();

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(
            [SELECT Id, Name FROM Enquiry__c WHERE Id IN :enquirylist]
        );
        ssc.setSelected(enquirylist); // Simulate selection

        // Step 3: Call the extension and method
        MassDeleteExtension controller = new MassDeleteExtension(ssc);
        PageReference result = controller.deleteSelected();

        Test.stopTest();

        // Step 4: Assert deletion
        List<Enquiry__c> check = [SELECT Id FROM Enquiry__c WHERE Id IN :enquirylist];
        System.assertEquals(0, check.size(), 'Enquiry records should be deleted.');

        // Step 5: Assert redirect URL
        System.assertNotEquals(null, result, 'PageReference should not be null');
        System.assert(result.getUrl().contains('/lightning/o/Enquiry__c/list'), 'Redirect URL should contain object path');
        System.assert(result.getUrl().contains('filterName=All_My_Open_Enquiries'), 'Redirect URL should contain the correct filter name');
    }
}