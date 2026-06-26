/**
* @File Name : ImagePDFGenerator.cls
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


public class ImagePDFGenerator {
    
    public static List<Id> generatePdfFromImages(Id recordId) {
        List<Id> resultIds = new List<Id>();
        
        	System.debug('generatePdfFromImages recordId'+recordId);
            PageReference pdfPage = Page.ImagePDFPage;
            pdfPage.getParameters().put('recordId', recordId);
        	ContentVersion pdfFile = new ContentVersion();
        	Blob pdfBlob;
        if(!test.isrunningtest()){
            pdfBlob = pdfPage.getContentAsPDF();
            System.debug('generatePdfFromImages pdfBlob'+pdfBlob);
            
        }else {
            String htmlContent = '<html><body><h1>Hello PDF</h1></body></html>';
            pdfBlob = Blob.toPDF(htmlContent);
        }
        pdfFile = new ContentVersion(
                Title = 'GeneratedImagePDF',
                PathOnClient = 'GeneratedImagePDF.pdf',
                VersionData = pdfBlob
            );
            insert pdfFile;
            System.debug('pdfFile'+pdfFile.Id);
            pdfFile = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :pdfFile.Id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = pdfFile.ContentDocumentId;
            cdl.LinkedEntityId = recordId; 
            cdl.ShareType = 'V'; 
            cdl.Visibility = 'AllUsers';
            //insert cdl;
            resultIds.add(pdfFile.Id);
        
        
        return resultIds;
    }
}