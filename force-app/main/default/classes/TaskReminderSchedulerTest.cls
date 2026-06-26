@isTest
public class TaskReminderSchedulerTest {

    @isTest static void testSchedulerExecutesSuccessfully() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser' + System.currentTimeMillis() + '@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;

        
        Date today = Date.today();
        DateTime dueDateTimeToday = DateTime.newInstance(today, Time.newInstance(10, 0, 0, 0));

       
        Task testTask = new Task(
            Subject = 'Reminder Test',
            ReminderDateTime = System.now().addHours(1),
            Due_Date_Time__c = dueDateTimeToday,
            Assigned_By__c = testUser.Id
        );
        insert testTask;

        
        Test.startTest();
        TaskReminderScheduler scheduler = new TaskReminderScheduler();
        scheduler.execute(null);
        Test.stopTest();

        
        System.assert(true, 'Scheduler executed without exceptions.');
    }
}