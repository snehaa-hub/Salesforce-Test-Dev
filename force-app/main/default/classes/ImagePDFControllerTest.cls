/**
* @File Name : GpsCameraImageController.cls
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
public class ImagePDFControllerTest {

 @isTest
    static void testImagePDFController() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        ContentVersion cv = new ContentVersion(
            Title = 'Test Image',
            PathOnClient = 'testImage.png',
            VersionData = Blob.valueOf('Fake image content'),
            IsMajorVersion = true
        );
        insert cv;

        Id contentDocId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('recordId', testAccount.Id);
        ImagePDFController controller = new ImagePDFController();
        List<String> imageList = controller.imageDataList;

        System.assertNotEquals(null, imageList, 'Image list should not be null');
        System.assert(imageList.size() > 0, 'Image list should contain at least one image');
        Test.stopTest();
    }
}