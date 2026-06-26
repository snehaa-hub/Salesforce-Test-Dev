// @isTest
// public class Task8AMEmailSenderTest {
//     @isTest static void testExecute() {
//         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
//         User ownerUser = new User(
//             Alias = 'owneru',
//             Email = 'owneruser' + DateTime.now().getTime() + '@example.com',
//             EmailEncodingKey = 'UTF-8',
//             LastName = 'OwnerUser',
//             LanguageLocaleKey = 'en_US',
//             LocaleSidKey = 'en_US',
//             ProfileId = p.Id,
//             TimeZoneSidKey = 'America/Los_Angeles',
//             UserName = 'owneruser' + DateTime.now().getTime() + '@example.com'
//         );
//         insert ownerUser;

//         Task task = new Task(
//             Subject = 'Scheduled Task',
//             Due_Date_Time__c = System.now().addDays(1),
//             OwnerId = ownerUser.Id,
//             Assigned_By__c = ownerUser.Id
//         );
//         insert task;

//         Test.startTest();
//         Task8AMEmailSender sched = new Task8AMEmailSender(task);
//         sched.execute(null);
//         Test.stopTest();
//     }
// }



@isTest
public class Task8AMEmailSenderTest {
    @isTest static void testExecute() {
        // Get profile to assign user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        // Create a User for Assigned_By__c
        User assignedByUser = new User(
            Alias = 'assbyu',
            Email = 'assignedbyuser' + DateTime.now().getTime() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'AssignedByUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'assignedbyuser' + DateTime.now().getTime() + '@example.com'
        );
        insert assignedByUser;

        // Create a Task with Assigned_By__c, Due_Date_Time__c and Subject
        Task task = new Task(
            Subject = 'Test Scheduled Task',
            Due_Date_Time__c = System.now().addDays(1),
            OwnerId = assignedByUser.Id,
            Assigned_By__c = assignedByUser.Id
        );
        insert task;

        // Re-query the Task including Subject, Due_Date_Time__c, Assigned_By__c fields
        task = [SELECT Id, Subject, Assigned_By__c, Due_Date_Time__c FROM Task WHERE Id = :task.Id LIMIT 1];

        Test.startTest();
        // Instantiate and execute schedulable class
        Task8AMEmailSender sched = new Task8AMEmailSender(task);
        sched.execute(null);
        Test.stopTest();
    }
}