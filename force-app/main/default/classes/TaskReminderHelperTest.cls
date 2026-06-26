@isTest
public class TaskReminderHelperTest {
    
    @isTest static void testCreateEmailForTask() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;

        Task t = new Task(
            Subject = 'Test Task',
            Due_Date_Time__c = System.now().addDays(1),
            Assigned_By__c = testUser.Id
        );
        insert t;

        Task taskWithUser = [
            SELECT Id, Subject, Due_Date_Time__c, Assigned_By__r.Email, Assigned_By__r.Name
            FROM Task WHERE Id = :t.Id
        ];

        Messaging.SingleEmailMessage email = TaskReminderHelper.createEmailForTask(taskWithUser);

        System.assertNotEquals(null, email, 'Email should be created');
        System.assertEquals(testUser.Email, email.getToAddresses()[0], 'Email recipient should match');
        System.assertEquals('Task Reminder', email.getSubject(), 'Email subject should be correct');
        System.assert(email.getPlainTextBody().contains('Test Task'), 'Email body should contain task subject');
    }

    @isTest static void testCreateEmailWithoutDueDate() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'NoDue',
            LastName = 'User',
            Email = 'nodueuser@example.com',
            Username = 'nodue' + System.currentTimeMillis() + '@example.com',
            Alias = 'ndue',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );
        insert testUser;

        Task t = new Task(
            Subject = 'No Due Date Task',
            Assigned_By__c = testUser.Id
           
        );
        insert t;

        Task taskWithUser = [
            SELECT Id, Subject, Due_Date_Time__c, Assigned_By__r.Email, Assigned_By__r.Name
            FROM Task WHERE Id = :t.Id
        ];

        Messaging.SingleEmailMessage email = TaskReminderHelper.createEmailForTask(taskWithUser);

        System.assertNotEquals(null, email, 'Email should be created');
        System.assert(email.getPlainTextBody().contains('No due date/time'), 'Email should mention no due date');
    }

    @isTest static void testCreateEmailWithNoAssignedBy() {
        Task t = new Task(
            Subject = 'No Assigned By Task',
            Due_Date_Time__c = System.now().addDays(2)
            
        );
        insert t;

        Task taskNoAssignedBy = [
            SELECT Id, Subject, Due_Date_Time__c, Assigned_By__r.Email, Assigned_By__r.Name
            FROM Task WHERE Id = :t.Id
        ];

        Messaging.SingleEmailMessage email = TaskReminderHelper.createEmailForTask(taskNoAssignedBy);

        System.assertEquals(null, email, 'Email should be null when Assigned_By__r is null');
    }
}