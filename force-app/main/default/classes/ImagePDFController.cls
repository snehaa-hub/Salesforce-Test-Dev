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

public class ImagePDFController {
public List<String> imageDataList { get; set; }

    public ImagePDFController() {
        Id recordId = ApexPages.currentPage().getParameters().get('recordId');
        imageDataList = new List<String>();

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];

        List<Id> docIds = new List<Id>();
        system.debug('recordId : '+recordId);
        
        for (ContentDocumentLink link : links) {
            docIds.add(link.ContentDocumentId);
        }
        system.debug('docIds : '+docIds);

        List<ContentVersion> versions = [
            SELECT VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN :docIds AND IsLatest = true
        ];

        for (ContentVersion cv : versions) {
           // imageDataList.add(EncodingUtil.base64Encode(cv.VersionData));
            imageDataList.add('/sfc/servlet.shepherd/version/download/' + cv.Id);
        }
    }
}