@isTest
public with sharing class CheckDuplicate_Test {

    @isTest static void checkDuplicateTestMethod(){
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
        
        Account acc1 = new Account();
        acc1.RecordTypeID = personAccountId;
        acc1.FirstName = 'Test';
        acc1.LastName = 'User';
        acc1.PersonEmail = 'TestUser@gmail.com';
        acc1.PersonMobilePhone = '65464453435';
        
        CheckDuplicate.Request req = new CheckDuplicate.Request();
        req.record = acc1;
        Assert.isNotNull(CheckDuplicate.execute(new List<CheckDuplicate.Request>{req}), 'String should not be null');
    }
}