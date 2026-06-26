@istest
public with sharing class FieldSetInfo_Test {
  /*  @isTest
    static void fieldSetInfoTestMethod() {
        String fieldSetName = 'Details_Business_Type_Of_Customer';
      //  Assert.isNotNull(FieldSetInfo.getFieldSet('', 'Applicant__c', fieldSetName), 'String should not be null');
    }*/
     @isTest static void EnquiryRestServiceTestMethod(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;
        
        Enquiry__c enquiry = new Enquiry__c();
        enquiry.Project__c = project.Id;
        enquiry.Status__c='New';
         enquiry.Mobile__c = '7894561235';
        insert enquiry;
        
        Map<String, String> enqMap = new Map<String, String>();

        enqMap.put('Project__c', enquiry.Project__c);
        enqMap.put('Status__c',enquiry.Status__c);
        enqMap.put('Site_Visit_Date__c',String.valueof(system.now().addHours(1)));
        Map<String, String> conMap = new Map<String, String>();
        conMap.put('PersonMobilePhone','65464453435');
        conMap.put('FirstName','Test');
        conMap.put('LastName','User');
        conMap.put('PersonEmail','TestUser@gmail.com');

        EnquiryRestService.EnquiryRequest enq = new EnquiryRestService.EnquiryRequest();
        enq.enquiryMap = enqMap;
        enq.contactMap = conMap;
        test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String sbody = JSON.serialize(enq);
        Blob blb = Blob.valueof(sbody);
        req.requestURI = '/services/apexrest/enquiry';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = blb;
        RestContext.request = req;
        RestContext.response= res;
        EnquiryRestService.doPost();
        test.stopTest();
    }
   
}