public class CaptureImageSiteVisit {
    
      @AuraEnabled(cacheable=true)
     public static List<String> getImageUrl(Id recordId) {
        List<String> imageUrls = new List<String>();

        System.debug('recordId: ' + recordId);

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];
        System.debug('links: ' + links);

        if (links.isEmpty()) return null;

       
        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            docIds.add(link.ContentDocumentId);
        }

        // Get the latest ContentVersion for each ContentDocumentId
        List<ContentVersion> versions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :docIds
            AND IsLatest = TRUE
        ];
        System.debug('versions: ' + versions);

        for (ContentVersion version : versions) {
            imageUrls.add('/sfc/servlet.shepherd/version/download/' + version.Id);
        }

        return imageUrls;
    }

}