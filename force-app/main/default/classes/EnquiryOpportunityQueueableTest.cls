@isTest
public class EnquiryOpportunityQueueableTest {

    @isTest
    static void testQueueableExecution() {
      
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Enquiry__c' AND Name = 'Tenant' LIMIT 1];

 
        Account acc = new Account(Name = 'Test Account');
        insert acc;

     
        Contact c = new Contact(
            LastName = 'Test Contact',
            AccountId = acc.Id
            
        );
        insert c;

     
        List<Enquiry__c> enquiryList = new List<Enquiry__c>{
            new Enquiry__c(
                Name = 'Test Enquiry 1',
                Status__c = 'Closed',
                Reason_for_Closed__c = 'Qualified',
                Mobile__c = '9876543210',
                RecordTypeId = rt.Id,
                Size_in_sqfts__c = 2500,
                Size_in_sqft__c = 'below 10000',
                Type_of_Unit__c = 'Land'
                
                
            ),
            new Enquiry__c(
                Name = 'Test Enquiry 2',
                Status__c = 'Closed',
                Reason_for_Closed__c = 'Qualified',
                Mobile__c = '9123456789',
                RecordTypeId = rt.Id,
                 Size_in_sqfts__c = 3000,
                Size_in_sqft__c = 'below 10000',
                Type_of_Unit__c = 'Land'
                
              
            )
        };
        insert enquiryList;

        EnquiryOpportunityQueueable queueJob = new EnquiryOpportunityQueueable(enquiryList);

        Test.startTest();
        System.enqueueJob(queueJob);
        Test.stopTest();

       
        List<Opportunity__c> opps = [
            SELECT Id, Name, Stage__c 
            FROM Opportunity__c 
            WHERE Enquiry__c IN :enquiryList
        ];


        for (Opportunity__c opp : opps) {
            System.assertEquals('Qualified', opp.Stage__c, 'Stage should be Qualified');
        }
    }
}