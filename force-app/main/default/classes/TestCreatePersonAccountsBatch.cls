@isTest
public class TestCreatePersonAccountsBatch {

    @isTest
    static void testBatchCreatesPersonAccounts() {
        // Step 1: Insert a record type for Person Account (mock)
        // In real orgs, Person Accounts must be enabled — this step assumes it exists.
        // Use dynamic fetching like in your batch

        // Step 2: Create Enquiry__c test data with no Contact_Person__c
        List<Enquiry__c> testEnquiries = new List<Enquiry__c>();
        for (Integer i = 0; i < 5; i++) {
            testEnquiries.add(new Enquiry__c(
                Name = 'Test User ' + i,
                Mobile__c = '999900000' + i,
                Email__c = 'usersre' + i + '@test.com'
                // Contact_Person__c is null by default
            ));
        }
        insert testEnquiries;

        // Step 3: Run the batch
        Test.startTest();
        
        CreatePersonAccountsBatch batch = new CreatePersonAccountsBatch();
        Database.executeBatch(batch, 50); // Batch size 2 to test chunking
       
        // Step 2: Schedule the class
        String cronExp = '0 0 0 1 1 ? 2050'; // A one-time run in the far future
       
        String jobId = System.schedule('TestScheduleCreatePersonAccountsBatch', cronExp, new ScheduleCreatePersonAccountsBatch());
        Test.stopTest();

        // Step 4: Assert that accounts are created
        List<Account> insertedAccounts = [SELECT Id, LastName, Phone, Email__c FROM Account WHERE Email__c LIKE '%@test.com'];
        System.assertEquals(5, insertedAccounts.size(), '5 Accounts should be inserted');

        // Step 5: Assert that Enquiry__c records are linked
        List<Enquiry__c> updatedEnquiries = [SELECT Id, Contact_Person__c FROM Enquiry__c WHERE Id IN :testEnquiries];
        for (Enquiry__c enq : updatedEnquiries) {
            System.assertNotEquals(null, enq.Contact_Person__c, 'Contact_Person__c should be populated');
        }
    }
}