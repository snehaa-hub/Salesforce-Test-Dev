/**
* @description This class that is used in FileOrganiser LWC Component.
*/
public with sharing class FileOrganiserHandler {
    
    /**
* @description This method is used to get all files related to a record
* @param recordId
* @return Details of files related to record in wrapper format
*/
    @AuraEnabled(cacheable=true)
    public static List<FileWrap> getFiles(Id recordId){
        
        List<FileWrap> filesLst = new List<FileWrap>();
        
        // Strip fields that are not readable
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, ContentDocumentId, ContentDocument.Title, 
             ContentDocument.ContentModifiedDate, 
             ContentDocument.LatestPublishedVersion.Document_Type__c, 
             ContentDocument.LatestPublishedVersionId,
             ContentDocument.LatestPublishedVersion.ContentModifiedBy.Name
             FROM ContentDocumentLink WHERE LinkedEntityId =: recordId 
             order By  ContentDocument.ContentModifiedDate DESC]);
        
        if(!(decision.getRecords()).isEmpty()) {
            for(ContentDocumentLink cDL: (List<ContentDocumentLink>) decision.getRecords()){
                
                FileWrap fWrap = new FileWrap();
                
                fWrap.id = cDL.ContentDocumentId;
                fWrap.title = cDL.ContentDocument.Title;
                fWrap.documentType = cDL.ContentDocument.LatestPublishedVersion.Document_Type__c;
                fWrap.uploadedBy = cDL.ContentDocument.LatestPublishedVersion.ContentModifiedBy.Name;
                fWrap.uploadedDate = cDL.ContentDocument.ContentModifiedDate;
                
                filesLst.add(fWrap);
            }
        }
        return filesLst;                    
    }
    
    /**
* @description This method is used to update files details(document type and SObject)
* @param recordId
* @param objType
* @param documentType
*/
    @AuraEnabled
    public static void updateFile(String recordId, String objType, String documentType){
        system.debug('recordId'+recordId);
        
        List<DocumentWrapper> documentList = (List<DocumentWrapper>) JSON.deserialize(recordId, List<DocumentWrapper>.class);
        Set<String> documentIdSet = new Set<String>();
        for (DocumentWrapper doc : documentList) {
            documentIdSet.add(doc.documentId);
        }
        
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Id, Title, SObjectType__c, Document_Type__c 
             FROM ContentVersion 
             WHERE ContentDocumentId IN: documentIdSet
             AND IsLatest = true]);
        
        List<ContentVersion> conversionVersionList = New List<ContentVersion> ();
        if(!(decision.getRecords()).isEmpty()) {
            List<ContentVersion> contentVersionList =  (List<ContentVersion>) decision.getRecords();
            for(ContentVersion thisContentVersion :contentVersionList){
                ContentVersion file = thisContentVersion;
                file.SObjectType__c = objType;
                file.Document_Type__c = documentType;
                conversionVersionList.add(file);
            }
            
            Schema.DescribeSObjectResult drSObj = Schema.sObjectType.ContentVersion;
            Boolean thisUserMayUpdate = drSObj.isUpdateable();
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.UPDATABLE, conversionVersionList);
            
            if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
                update securityDecision.getRecords();
            }
        }
    }
    @AuraEnabled
public static String uploadFile(String fileName, String base64Data, Id recordId) {
    Blob body = EncodingUtil.base64Decode(base64Data);

    ContentVersion cv = new ContentVersion();
    cv.Title = fileName;
    cv.PathOnClient = fileName;
    cv.VersionData = body;
    insert cv;

    cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

    ContentDocumentLink link = new ContentDocumentLink();
    link.ContentDocumentId = cv.ContentDocumentId;
    link.LinkedEntityId = recordId;
    link.ShareType = 'V';
    insert link;

    return cv.ContentDocumentId;
}
    
    /**
* @description Wrapper class to set file data
*/
    public class FileWrap{
        
        @AuraEnabled
        public String id;
        
        @AuraEnabled
        public String title;
        
        @AuraEnabled
        public String documentType;
        
        @AuraEnabled
        public Datetime uploadedDate;
        
        @AuraEnabled
        public String uploadedBy;
    }
    
    public class DocumentWrapper {
        public String documentId;
    }


    

}