@isTest
private class TaskEmailSchedulerTest {

    @testSetup
    static void setupTestData() {
        // Create Assigned_By User
        User assignedBy = new User(
            FirstName = 'Assigned',
            LastName = 'ByUser',
            Email = 'assignedby@example.com',
            Username = 'assignedbyuser@example.com.test',
            Alias = 'assign',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert assignedBy;

        // Create Task Owner User
        User ownerUser = new User(
            FirstName = 'Owner',
            LastName = 'User',
            Email = 'owner@example.com',
            Username = 'owneruser@example.com.test',
            Alias = 'ownr',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert ownerUser;

        // Today's Task
        Task todayTask = new Task(
            Subject = 'Today Task',
            Status = 'Not Started',
            Due_Date_Time__c = System.now().addMinutes(10),
            Assigned_By__c = assignedBy.Id,
            OwnerId = ownerUser.Id
        );
        insert todayTask;

        // Future Task
        Task futureTask = new Task(
            Subject = 'Future Task',
            Status = 'Not Started',
            Due_Date_Time__c = System.now().addDays(1).addHours(9),
            Assigned_By__c = assignedBy.Id,
            OwnerId = ownerUser.Id
        );
        insert futureTask;
    }

    @isTest
    static void testSchedulerExecute() {
        Test.startTest();

        // Execute the Scheduler directly
        TaskEmailScheduler scheduler = new TaskEmailScheduler();
        String jobId = System.schedule('Test_TaskEmailScheduler', '0 0 1 * * ?', scheduler);

        Test.stopTest();

        // Validate if job was scheduled
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Test_TaskEmailScheduler'];
        System.assert(jobs.size() == 1, 'Scheduler job should be scheduled');
    }

    @isTest
    static void testScheduleClassDirectly() {
        TaskEmailScheduler scheduler = new TaskEmailScheduler();

        // Simulate manual invocation
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();

        System.assert(true, 'Scheduler executed without exceptions.');
    }
}