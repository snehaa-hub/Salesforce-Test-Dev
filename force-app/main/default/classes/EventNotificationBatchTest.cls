@istest
public class EventNotificationBatchTest {

   @testSetup
    static void setupData() {
        // Create a test User (who will be linked as Event_Attendee__r)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Other',
        LastName = 'User',
        Email = 'otheruser@example.com',
        Username = 'otheruser@example.com.test',
        Alias = 'ouser',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;

        // Create an Event__c record for today
        Event__c ev = new Event__c(
          
            Subject__c = 'Salesforce Batch Test Event',
            StartDateTime__c = DateTime.now().addHours(2), // within today
            EndDateTime__c   = DateTime.now().addHours(4)
        );
        insert ev;

        // Create Event_Attendee__c linked to the User
        Event_Attendee__c attendee = new Event_Attendee__c(
            Name = 'Attendee1',
            Event__c = ev.Id,
            Event_Attendee__c = testUser.Id  // Lookup to User
        );
        insert attendee;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        // Run the batch
        EventNotificationBatch batch = new EventNotificationBatch();
        Database.executeBatch(batch, 50);
        Test.stopTest();


}
}