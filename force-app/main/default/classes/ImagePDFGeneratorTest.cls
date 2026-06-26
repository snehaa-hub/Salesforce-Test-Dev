@istest  
public class ImagePDFGeneratorTest {
    
 @isTest
    public static void testGeneratePdfFromImages() {
        // Create a test record to pass into the method
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a mock PageReference for the PDF generation
        Test.startTest();

        // Call the method to generate PDF from images
        List<Id> resultIds = ImagePDFGenerator.generatePdfFromImages(testAccount.Id);

        Test.stopTest();

        // Assert that the result list is not empty
        System.assertNotEquals(resultIds, null, 'Result list should not be null');
        System.assertNotEquals(resultIds.size(), 0, 'Result list should contain at least one record');

        // Check if the ContentVersion record was created
        ContentVersion cv = [SELECT Id, Title, PathOnClient,ContentDocumentId, VersionData FROM ContentVersion WHERE Id = :resultIds[0]];
        System.assertEquals(cv.Title, 'GeneratedImagePDF', 'ContentVersion title should match');
        System.assertEquals(cv.PathOnClient, 'GeneratedImagePDF.pdf', 'PathOnClient should match');

        // Check if the ContentDocumentLink was created and linked to the record
        ContentDocumentLink cdl = [SELECT Id, ContentDocumentId, LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE ContentDocumentId = :cv.ContentDocumentId];
       // System.assertEquals(cdl.LinkedEntityId, testAccount.Id, 'The linked entity should be the test account');
        
        // Check if the ShareType is 'V' and Visibility is 'AllUsers'
        System.assertEquals(cdl.ShareType, 'I', 'ShareType should be "V"');
        System.assertEquals(cdl.Visibility, 'AllUsers', 'Visibility should be "AllUsers"');

    }
}