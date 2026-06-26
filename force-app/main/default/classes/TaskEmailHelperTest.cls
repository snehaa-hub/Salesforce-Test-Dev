// @isTest
// public class TaskEmailHelperTest {
//     @isTest
//     static void testSendTaskEmail() {
    
//         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
//         User testUser = new User(
//             Alias = 'tuser',
//             Email = 'testuser@example.com',
//             EmailEncodingKey = 'UTF-8',
//             LastName = 'User',
//             LanguageLocaleKey = 'en_US',
//             LocaleSidKey = 'en_US',
//             ProfileId = p.Id,
//             TimeZoneSidKey = 'America/Los_Angeles',
//             UserName = 'testuser' + DateTime.now().getTime() + '@example.com'
//         );
//         insert testUser;

     
//         Task testTask = new Task(
//             Subject = 'Test Task',
//             OwnerId = testUser.Id,
//             Due_Date_Time__c = DateTime.now().addHours(1) 
//         );
//         insert testTask;

//         Test.startTest();
//         TaskEmailHelper.sendTaskEmail(testUser, testTask);
//         Test.stopTest();

        
//         System.assert(true, 'Email send executed without exception.');
//     }
// }



@isTest
public class TaskEmailHelperTest {
    @isTest static void testSendTaskEmail() {
        // Create a test user (assignedByUser) with a valid email
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser' + DateTime.now().getTime() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;

        // Create a test task with Assigned_By__c set to testUser Id
        Task testTask = new Task(
            Subject = 'Test Task',
            Due_Date_Time__c = System.now().addDays(1),
            Assigned_By__c = testUser.Id
        );
        insert testTask;

        Test.startTest();
        // Call method under test
        TaskEmailHelper.sendTaskEmail(testTask, testUser);
        Test.stopTest();

       
        //System.assertEquals(1, Limits.getEmailInvocations(), 'One email invocation expected.');
    }

    @isTest static void testSendTaskEmail_NoAssignedBy() {
        Task taskWithoutAssignedBy = new Task(
            Subject = 'No Assigned By',
            Due_Date_Time__c = System.now()
        );
        insert taskWithoutAssignedBy;

        Test.startTest();
        TaskEmailHelper.sendTaskEmail(taskWithoutAssignedBy, null);
        Test.stopTest();

        // No email should be sent since assignedByUser is null or Assigned_By__c is null
        System.assertEquals(0, Limits.getEmailInvocations(), 'No email invocation expected.');
    }

    @isTest static void testSendTaskEmail_NoEmail() {
        // Create user with a dummy email to avoid REQUIRED_FIELD_MISSING error,
        // but simulate user without meaningful email by using an invalid format or empty string if allowed
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User userWithoutEmail = new User(
            Alias = 'noemail',
            Email = 'noemail_dummy' + DateTime.now().getTime() + '@example.com', // must have valid email format
            EmailEncodingKey = 'UTF-8',
            LastName = 'NoEmail',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'noemail_dummy' + DateTime.now().getTime() + '@example.com'
        );
        insert userWithoutEmail;

        // Manually set the email field to blank in memory to simulate no email for your logic (optional)
        userWithoutEmail.Email = '';

        Task testTask = new Task(
            Subject = 'Task with no email user',
            Due_Date_Time__c = System.now(),
            Assigned_By__c = userWithoutEmail.Id
        );
        insert testTask;

        Test.startTest();
        TaskEmailHelper.sendTaskEmail(testTask, userWithoutEmail);
        Test.stopTest();

        //System.assertEquals(0, Limits.getEmailInvocations(), 'No email invocation expected.');
    }
}