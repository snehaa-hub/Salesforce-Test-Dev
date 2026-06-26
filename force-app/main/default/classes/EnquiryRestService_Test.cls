@istest
public with sharing class EnquiryRestService_Test {

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
    
    @isTest static void EnquiryRestServiceTestMethod1(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID = personAccountId;
        acc.FirstName = 'Test';
        acc.LastName = 'User';
        acc.PersonEmail = 'TestUser@gmail.com';
        acc.PersonMobilePhone = '65464453435';
        insert acc;
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;
        
        Enquiry__c enquiry = new Enquiry__c();
        enquiry.Project__c = project.Id;
        enquiry.Status__c='New';
        enquiry.Mobile__c = '7894561236';
        insert enquiry;
        
        Map<String, String> enqMap = new Map<String, String>();
        enqMap.put('Project__c', enquiry.Project__c);
        enqMap.put('Status__c',enquiry.Status__c);
        enqMap.put('Site_Visit_Date__c',String.valueof(system.now().addHours(1)));
        Map<String, String> conMap = new Map<String, String>();
        conMap.put('PersonMobilePhone',acc.PersonMobilePhone);
        conMap.put('LastName',acc.LastName);
        conMap.put('PersonEmail',acc.PersonEmail);

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

    @isTest static void EnquiryRestServiceTestMethod2(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID = personAccountId;
        acc.FirstName = 'Test';
        acc.LastName = 'User';
        acc.PersonEmail = 'TestUser@gmail.com';
        acc.PersonMobilePhone = '65464453435';
        insert acc;
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;
        
        Enquiry__c enquiry = new Enquiry__c();
        enquiry.Project__c = project.Id;
        enquiry.Status__c='New';
        enquiry.Mobile__c = '7894561237';
        insert enquiry;
        
        Map<String, String> enqMap = new Map<String, String>();
        enqMap.put('Id', enquiry.Id);
        enqMap.put('Project__c', enquiry.Project__c);
        enqMap.put('Status__c',enquiry.Status__c);
        enqMap.put('Site_Visit_Date__c',String.valueof(system.now().addHours(1)));
        Map<String, String> conMap = new Map<String, String>();
        conMap.put('PersonMobilePhone',acc.PersonMobilePhone);
        conMap.put('FirstName',acc.FirstName);
        conMap.put('LastName',acc.LastName);
        conMap.put('PersonEmail',acc.PersonEmail);

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

    @isTest static void EnquiryRestServiceTestMethod3(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID = personAccountId;
        acc.FirstName = 'Test';
        acc.LastName = 'User';
        acc.PersonEmail = 'TestUser@gmail.com';
        acc.PersonMobilePhone = '65464453435';
        insert acc;
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;
        
        Enquiry__c enquiry = new Enquiry__c();
        enquiry.Project__c = project.Id;
        enquiry.Status__c='New';
        enquiry.Mobile__c = '7894561238';
        insert enquiry;
        
        Map<String, String> enqMap = new Map<String, String>();
        enqMap.put('Project__c', enquiry.Project__c);
        enqMap.put('Status__c',enquiry.Status__c);
        enqMap.put('Site_Visit_Date__c',String.valueof(system.now().addHours(1)));
        Map<String, String> conMap = new Map<String, String>();
        conMap.put('PersonMobilePhone',acc.PersonMobilePhone);
        conMap.put('FirstName',acc.FirstName);
        conMap.put('LastName',acc.LastName);
        conMap.put('PersonEmail',acc.PersonEmail);

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

    @isTest static void EnquiryRestServiceTestMethod4(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID = personAccountId;
        acc.FirstName = 'Test';
        acc.LastName = 'User';
        acc.PersonEmail = 'TestUser@gmail.com';
        acc.PersonMobilePhone = '65464453435';
        insert acc;
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;
        
        Enquiry__c enquiry = new Enquiry__c();
        enquiry.Project__c = project.Id;
        enquiry.Status__c='New';
        enquiry.Mobile__c = '7894561239';
        insert enquiry;
        
        Map<String, String> enqMap = new Map<String, String>();
        enqMap.put('Project__c', enquiry.Project__c);
        enqMap.put('Status__c',enquiry.Status__c);
        enqMap.put('Site_Visit_Date__c',String.valueof(system.now().addHours(1)));
        Map<String, String> conMap = new Map<String, String>();
        conMap.put('PersonMobilePhone',acc.PersonMobilePhone);
        conMap.put('FirstName',acc.FirstName);
        conMap.put('LastName',acc.LastName);
        conMap.put('PersonEmail','TestUser1@gmail.com');

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

    @isTest static void EnquiryRestServiceTestMethod5(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID = personAccountId;
        acc.FirstName = 'Test';
        acc.LastName = 'User';
        acc.PersonEmail = 'TestUser@gmail.com';
        acc.PersonMobilePhone = '65464453435';
        acc.Salutation = 'Mr';
        insert acc;
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;
        
        Enquiry__c enquiry = new Enquiry__c();
        enquiry.Project__c = project.Id;
        enquiry.Status__c='New';
        enquiry.Mobile__c = '7894561230';
        insert enquiry;
        
        Map<String, String> enqMap = new Map<String, String>();
        enqMap.put('Project__c', enquiry.Project__c);
        enqMap.put('Status__c',enquiry.Status__c);
        enqMap.put('Site_Visit_Date__c',String.valueof(system.now().addHours(1)));
        Map<String, String> conMap = new Map<String, String>();
        conMap.put('PersonMobilePhone',acc.PersonMobilePhone);
        conMap.put('FirstName',acc.FirstName);
        conMap.put('LastName',acc.LastName);
        conMap.put('PersonEmail','TestUser1@gmail.com');
        conMap.put('Salutation','Mr');

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

    @isTest static void EnquiryRestServiceTestMethod6(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID = personAccountId;
        acc.FirstName = 'Test';
        acc.LastName = 'User';
        acc.PersonEmail = 'TestUser@gmail.com';
        acc.PersonMobilePhone = '65464453435';
        acc.Salutation = 'Mr';
        insert acc;
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;
        
        Enquiry__c enquiry = new Enquiry__c();
        enquiry.Project__c = project.Id;
        enquiry.Status__c='New';
        enquiry.Mobile__c = '7894561245';
        insert enquiry;

      List<BusinessHours> bhs = [SELECT Id 
                                    FROM BusinessHours 
                                    WHERE IsDefault=true];
        
        Map<String, String> enqMap = new Map<String, String>();
        enqMap.put('Project__c', enquiry.Project__c);
        enqMap.put('Status__c',enquiry.Status__c);
        enqMap.put('Site_Visit_Date__c',String.valueof(system.now().addHours(1)));
        enqMap.put('Site_Visit_Location__c', bhs[0].Id);
        Map<String, String> conMap = new Map<String, String>();
        conMap.put('PersonMobilePhone',acc.PersonMobilePhone);
        conMap.put('FirstName',acc.FirstName);
        conMap.put('LastName',acc.LastName);
        conMap.put('PersonEmail','TestUser1@gmail.com');
        conMap.put('Salutation','Mr');

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

    @isTest static void EnquiryRestServiceTestMethod7(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID = personAccountId;
        acc.FirstName = 'Test';
        acc.LastName = 'User';
        acc.PersonEmail = 'TestUser@gmail.com';
        acc.PersonMobilePhone = '65464453435';
        acc.Salutation = 'Mr';
        insert acc;
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;
        
        Enquiry__c enquiry = new Enquiry__c();
        enquiry.Project__c = project.Id;
        enquiry.Status__c='New';
        enquiry.Mobile__c = '7894561535';
        insert enquiry;

        Site_Visit__c siteVisit = new Site_Visit__c();
        siteVisit.Enquiry__c = enquiry.Id;
        siteVisit.Status__c = 'Scheduled';

        insert siteVisit;

List<BusinessHours> bhs = [SELECT Id 
                                    FROM BusinessHours 
                                    WHERE IsDefault=true];
        
        Map<String, String> enqMap = new Map<String, String>();
        enqMap.put('Id', enquiry.Id);
        enqMap.put('Project__c', enquiry.Project__c);
        enqMap.put('Status__c',enquiry.Status__c);
        enqMap.put('Site_Visit_Date__c',String.valueof(system.now().addHours(1)));
        enqMap.put('Site_Visit_Location__c', bhs[0].Id);
        Map<String, String> conMap = new Map<String, String>();
        conMap.put('PersonMobilePhone',acc.PersonMobilePhone);
        conMap.put('FirstName',acc.FirstName);
        conMap.put('LastName',acc.LastName);
        conMap.put('PersonEmail','TestUser1@gmail.com');
        conMap.put('Salutation','Mr');

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
    
      @isTest static void EnquiryRestServiceTestMethod8(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID = personAccountId;
        acc.FirstName = 'Test';
     	 acc.LastName = 'User';
        acc.PersonEmail = 'TestUser@gmail.com';
        acc.PersonMobilePhone = '65464453435';
        acc.Salutation = 'Mr';
        insert acc;
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;
        
        Enquiry__c enquiry = new Enquiry__c();
        enquiry.Project__c = project.Id;
         
        enquiry.Status__c='New';
          enquiry.Mobile__c = '7895561235';
        insert enquiry;
        
        Map<String, String> enqMap = new Map<String, String>();
        enqMap.put('Project__c', enquiry.Project__c);
        enqMap.put('Status__c',enquiry.Status__c);
        enqMap.put('Site_Visit_Date__c',String.valueof(system.now().addHours(1)));
        Map<String, String> conMap = new Map<String, String>();
        conMap.put('PersonMobilePhone',acc.PersonMobilePhone);
       conMap.put('FirstName','');
       	conMap.put('LastName','');
        conMap.put('PersonEmail','TestUser1@gmail.com');
        conMap.put('Salutation','');

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
    
     @isTest static void EnquiryRestServiceTestMethod9(){
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();

        Account acc = new Account();
        acc.RecordTypeID = personAccountId;
        acc.FirstName = 'Test';
     	 acc.LastName = 'User';
        acc.PersonEmail = 'TestUser@gmail.com';
        acc.PersonMobilePhone = '65464453435';
        acc.Salutation = 'Mr';
        insert acc;
        
        Project__c project = new Project__c();
        project.Name = 'Test Project';
        insert project;
        
        Enquiry__c enquiry = new Enquiry__c();
        enquiry.Project__c = project.Id;
         
        enquiry.Status__c='New';
         enquiry.Mobile__c = '7894561535';
        insert enquiry;
        
        Map<String, String> enqMap = new Map<String, String>();
        enqMap.put('Project__c', enquiry.Project__c);
        enqMap.put('Status__c',enquiry.Status__c);
		 enqMap.put('Site_Visit_Date__c',String.valueof(system.now().addHours(1)));
        Map<String, String> conMap = new Map<String, String>();
        conMap.put('PersonMobilePhone',acc.PersonMobilePhone);
       conMap.put('FirstName','');
       	conMap.put('LastName','');
        conMap.put('PersonEmail','TestUser1@gmail.com');
        conMap.put('Salutation','');

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