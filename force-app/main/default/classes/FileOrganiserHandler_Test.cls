@isTest
public class FileOrganiserHandler_Test {
    @isTest
    static void fileOrganiserHandlerTestMethod() {
        Account projObject = new Account(Name = 'Test Project');
        insert projObject;
        
        ContentVersion content = new ContentVersion();
        content.Title = 'Header_Picture1';
        content.PathOnClient = '/' + content.Title + '.jpg';
        content.SObjectType__c = 'Account';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData = bodyBlob;
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = projObject.id;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        contentlink.ContentDocumentId = [SELECT contentdocumentid FROM contentversion WHERE id = :content.id]
            .contentdocumentid;
        insert contentlink;
        
        Test.startTest();
        
        FileOrganiserHandler.FileWrap fWrap = new FileOrganiserHandler.FileWrap();
        fWrap.title = 'Test';
        fWrap.id = projObject.id;
        String jsonString = '[{"documentId":"'+contentlink.ContentDocumentId+'"}]';
        FileOrganiserHandler.getFiles(projObject.id);
        FileOrganiserHandler.updateFile(
            jsonString,
            content.SObjectType__c,
            content.Document_Type__c
        );
        Assert.isNotNull(FileOrganiserHandler.getFiles(projObject.id), 'String should not be null');
        Test.stopTest();
    }
    @isTest
    static void testUploadFile() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        String fileName = 'testFile.txt';
        String fileContent = 'Hello, this is a test file!';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf(fileContent));

        Test.startTest();
        String contentDocId = FileOrganiserHandler.uploadFile(fileName, base64Data, acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, contentDocId, 'ContentDocumentId should not be null');

        ContentDocument doc = [
            SELECT Id 
            FROM ContentDocument 
            WHERE Id = :contentDocId
        ];
        System.assertEquals(contentDocId, doc.Id);

        ContentDocumentLink link = [
            SELECT Id, LinkedEntityId, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :contentDocId
            LIMIT 1
        ];

        System.assertEquals(acc.Id, link.LinkedEntityId);
        System.assertEquals(contentDocId, link.ContentDocumentId);
    }
}