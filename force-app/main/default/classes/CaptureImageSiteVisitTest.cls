@isTest
public class CaptureImageSiteVisitTest {
    @isTest
    static void testGetImageUrl() {
        // Create a mock record (e.g., Account)
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a ContentVersion (automatically creates a ContentDocument)
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Image',
            PathOnClient = 'testimage.jpg',
            VersionData = Blob.valueOf('Test image content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Query the ContentDocumentId (it is set after insert)
        contentVersion = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersion.Id
        ];

        // Link the ContentDocument to the test record
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = contentVersion.ContentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;

        // Call the method
        Test.startTest();
        List<String> imageUrls = CaptureImageSiteVisit.getImageUrl(testAccount.Id);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, imageUrls, 'Image URLs list should not be null');
        System.assertEquals(1, imageUrls.size(), 'There should be one image URL returned');
        System.assert(imageUrls[0].contains(contentVersion.Id), 'URL should contain the ContentVersion Id');
    }
}