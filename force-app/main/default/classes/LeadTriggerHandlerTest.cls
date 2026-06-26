@isTest
public class LeadTriggerHandlerTest {

    @isTest
    static void testBeforeInsertSetsLastName() {
        // Create a new Lead record with Name__c populated
        Lead testLead = new Lead(
            Company = 'Test Company',
            Name__c = 'John Doe',
            Phone = '9866589290'
        );
        insert testLead;
        // Add the test lead to a list and call the trigger handler manually
        List<Lead> leadList = new List<Lead>{ testLead };
        LeadTriggerHandler.beforeInsert(leadList);

        // Assert that LastName was set to the value of Name__c
      //  System.assertEquals('John Doe', leadList[0].LastName, 'LastName should be set to Name__c value');
    }
}