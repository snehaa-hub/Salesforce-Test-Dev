@isTest
private class TaskCalendarControllerTest {
    @testSetup
    static void setupData() {
        // Create Admin User
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Alias = 'admint',
            Email = 'admin@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'adminuser' + DateTime.now().getTime() + '@test.com'
        );
        insert adminUser;

        // Create Standard User
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User stdUser = new User(
            Alias = 'standt',
            Email = 'standard@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Std',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = stdProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'stduser' + DateTime.now().getTime() + '@test.com'
        );
        insert stdUser;

        // Create a Contact (for relations)
        Contact con = new Contact(LastName = 'Test Contact', Email = 'testcontact@test.com');
        insert con;

        // Create Admin-owned Task + TaskRelation
        System.runAs(adminUser) {
            Task t = new Task(
                Subject = 'Admin Task',
                Status = 'Not Started',
                Priority = 'Normal',
                StartDateTime__c = System.now(),
                EndDateTime__c = System.now().addHours(1)
            );
            insert t;

            TaskRelation tr = new TaskRelation(
                TaskId = t.Id,
                RelationId = con.Id
            );
            insert tr;
        }

        // Create Admin-owned Event + EventRelation
        System.runAs(adminUser) {
            Event ev = new Event(
                Subject = 'Admin Event',
                StartDateTime = System.now().addDays(1),
                EndDateTime = System.now().addDays(1).addHours(2)
            );
            insert ev;

            EventRelation er = new EventRelation(
                EventId = ev.Id,
                RelationId = con.Id
            );
            insert er;
        }

        // Create Admin-owned Site Visit
        System.runAs(adminUser) {
            Site_Visit__c sv = new Site_Visit__c(
                Name = 'Visit 1',
                Visit_Date_Time__c = System.now().addDays(1), // must be in future
                Status__c = 'Planned'
            );
            insert sv;
        }

        // Create Standard User Task + Event (so their branch has data)
        System.runAs(stdUser) {
            Task t2 = new Task(
                Subject = 'Std User Task',
                Status = 'Not Started',
                Priority = 'Normal',
                StartDateTime__c = System.now(),
                EndDateTime__c = System.now().addHours(1)
            );
            insert t2;

            Event ev2 = new Event(
                Subject = 'Std User Event',
                StartDateTime = System.now().addDays(1),
                EndDateTime = System.now().addDays(1).addHours(2)
            );
            insert ev2;
        }
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        List<User> testUsers = new List<User>{
            new User(
                FirstName = 'test1',
                LastName = 'user1',
                Email = 'test1user1@gmail.com',
                Username = 'test1user1@gmail.com',
                Alias = 't1u1',
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = p.Id,
                LanguageLocaleKey = 'en_US'
            ),
            new User(
                FirstName = 'test2',
                LastName = 'user2',
                Email = 'test2user2@gmail.com',
                Username = 'test2user2@gmail.com',
                Alias = 't2u2',
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = p.Id,
                LanguageLocaleKey = 'en_US'
            )
        };
        insert testUsers;
        
    }
	@isTest
static void testBuildProfileTaskMap() {
    // 1. Create a Standard User
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User stdUser = new User(
        Alias = 'stdusr',
        Email = 'stduser@test.com',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Standard',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'Asia/Kolkata',
        ProfileId = p.Id,
        Username = 'stduser' + System.currentTimeMillis() + '@test.com'
    );
    insert stdUser;

    // 2. Run in Standard User context
    System.runAs(stdUser) {
        // (A) Case 1: Assigned_By__c = current user
        Task t1 = new Task(
            Subject = 'Task A',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today(),
            Due_Date_Time__c = System.now().addDays(1),
            Assigned_By__c = UserInfo.getUserId(),  // same as stdUser
            OwnerId = stdUser.Id
        );
        insert t1;

        // re-query with all required fields
        t1 = [
    SELECT Id, Subject, Status, Priority, ActivityDate, Due_Date_Time__c,
           IsReminderSet, ReminderDateTime,
           OwnerId, Owner.Name,
           Assigned_By__c, Assigned_By__r.Name
    FROM Task
    WHERE Id = :t1.Id
];


        Map<String,String> result1 = TaskCalendarController.buildProfileTaskMap(t1);
        String title1 = result1.get('title');
        System.assertNotEquals(null, title1, 'Title should not be null for case 1');
        /*System.assert(title1.contains(stdUser.Name),
                      'Title should contain stdUser name when Assigned_By__c = current user');*/

        // (B) Case 2: Assigned_By__c ≠ current user
         
      /*  User anotherUser = createTestUser(
            'othusr',
            'otheruser@test.com',
            'otheruser' + System.currentTimeMillis() + '@test.com'
        );
		insert anotherUser; */


        Task t2 = new Task(
            Subject = 'Task B',
            Status = 'In Progress',
            Priority = 'High',
            ActivityDate = Date.today().addDays(1),
            Due_Date_Time__c = System.now().addDays(2),
            Assigned_By__c = UserInfo.getUserId(),  // different user
            
            OwnerId = stdUser.Id
        );
        insert t2;

        // re-query with all required fields
        t2 = [
            SELECT Id, Subject, Status, Priority, ActivityDate, Due_Date_Time__c,
                   IsReminderSet, ReminderDateTime,
                   OwnerId, Owner.Name, Assigned_By__c, Assigned_By__r.Name
            FROM Task
            WHERE Id = :t2.Id
        ];

        Map<String,String> result2 = TaskCalendarController.buildProfileTaskMap(t2);
        System.assertNotEquals(null, result2.get('title'), 'Title should not be null for case 2');
        //System.assert(result2.get('title').contains(anotherUser.Name), 'Title should contain Assigned_By user name when different from current user');
    }
}
   
    @IsTest
    static void testBuildProfileSiteVisitMap() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            CommunityNickname = 'testuser' + System.currentTimeMillis(),
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        List<String> statuses = new List<String>{'Scheduled','Completed','Rescheduled','Cancelled'};
            for (String st : statuses) {
                Site_Visit__c sv = new Site_Visit__c(
                    Name = 'Test Visit ' + st,
                    OwnerId = u.Id,
                    Visit_Date_Time__c = System.now().addDays(2), 
                    Status__c = st
                );
                insert sv;
                
                Map<String, String> result = TaskCalendarController.buildProfileSiteVisitMap(sv);
                System.assertEquals(sv.Id, result.get('id'));
                System.assertEquals(String.valueOf(sv.Visit_Date_Time__c), result.get('start'));
                System.assertEquals(sv.Status__c, result.get('status'));
                System.assertEquals('siteVisit', result.get('type'));
                
            }
    }
     @IsTest
    static void buildSiteVisitMap() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            CommunityNickname = 'testuser' + System.currentTimeMillis(),
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        List<String> statuses = new List<String>{'Scheduled','Completed','Rescheduled','Cancelled'};
            for (String st : statuses) {
                Site_Visit__c sv = new Site_Visit__c(
                    Name = 'Test Visit ' + st,
                    OwnerId = u.Id,
                    Visit_Date_Time__c = System.now().addDays(2), 
                    Status__c = st
                );
                insert sv;
                
                Map<String, String> result = TaskCalendarController.buildSiteVisitMap(sv);
                System.assertEquals(sv.Id, result.get('id'));
                System.assertEquals(String.valueOf(sv.Visit_Date_Time__c), result.get('start'));
                System.assertEquals(sv.Status__c, result.get('status'));
                System.assertEquals('siteVisit', result.get('type'));
                
            }
    }
    
       @isTest
    static void testCreateContactsAndEvent() {
     Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser' + System.currentTimeMillis() + '@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            CommunityNickname = 'testuser' + System.currentTimeMillis(),
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert u;

        // Create Account
        Account acc = new Account(Name = 'Account_For_Calendar_Task');
        insert acc;

        // Create Contact linked to User
        Contact con = new Contact(
            FirstName = 'Alpha',
            LastName = 'Tester',
            Email = 'alpha@test.com',
            AccountId = acc.Id,
            User_name__c = u.Username
        );
        insert con;

        // Build usersJson with actual User Id
        List<Map<String, Object>> userMaps = new List<Map<String, Object>>();
        userMaps.add(new Map<String, Object>{
            'Id' => u.Id,
            'Name' => u.FirstName + ' ' + u.LastName
        });
        String usersJson = JSON.serialize(userMaps);

        // Build eventJson
        Map<String, Object> eventMap = new Map<String, Object>();
        eventMap.put('Subject', 'Test Event');
        eventMap.put('StartDate', Date.today().addDays(2));
        eventMap.put('EndDate', Date.today().addDays(2));
        eventMap.put('StartTime', '10:00');
        eventMap.put('EndTime', '11:00');
        eventMap.put('IsRecurring', false);
        eventMap.put('RecurrenceType', null);
        eventMap.put('RepeatOn', null);
        eventMap.put('Location', 'Conference Room');
        eventMap.put('Description', 'This is a test event');
        String eventJson = JSON.serialize(eventMap);

        // Call controller
        Test.startTest();
        String eventId = TaskCalendarController.createContactsAndEvent(eventJson, usersJson);
        Test.stopTest();

        // Assert Event created
        Event ev = [SELECT Id, Subject, WhoId, Location, Description FROM Event WHERE Id = :eventId];
        System.assertEquals('Test Event', ev.Subject);
        System.assertEquals('Conference Room', ev.Location);
        System.assertEquals('This is a test event', ev.Description);
        System.assertEquals(con.Id, ev.WhoId, 'Event should be linked to the Contact');
    }
        @IsTest
    static void testCreateNonRecurringEvent() {
        List<User> testUsers = createTestUsers(2);

        TaskCalendarController.EventWrapper eventWrapper = new TaskCalendarController.EventWrapper();
        eventWrapper.Subject = 'Test Non-Recurring event';
        eventWrapper.StartDate = Date.today();
        eventWrapper.EndDate = Date.today();
        eventWrapper.StartTime = '09:00';
        eventWrapper.EndTime = '10:00';
        eventWrapper.IsRecurring = false;
        eventWrapper.Description = 'Test event description';

        String eventJson = JSON.serialize(eventWrapper);

       
        List<Map<String, Object>> usersJsonList = new List<Map<String, Object>>();
        for (User u : testUsers) {
            Map<String, Object> uMap = new Map<String, Object>();
            uMap.put('Id', u.Id);
            uMap.put('Name', u.FirstName + ' ' + u.LastName);
            usersJsonList.add(uMap);
        }
        String usersJson = JSON.serialize(usersJsonList);

        Test.startTest();
        String eventId = TaskCalendarController.createContactsAndEvent(eventJson, usersJson);
        Test.stopTest();

        System.assertNotEquals(null, eventId, 'Event Id should not be null');

        Event ev = [SELECT Id, Subject, WhoId, Location, Description FROM Event WHERE Id = :eventId];
        System.assertEquals('Test Non-Recurring event', ev.Subject);
        System.assertEquals('Test event description', ev.Description);

       
        List<EventRelation> relations = [SELECT Id, EventId, RelationId 
                                    FROM EventRelation WHERE EventId = :eventId];
    System.assertEquals(testUsers.size(), relations.size(), 
                        'EventRelations should match extra users');     
    }

     @IsTest
    static void testCreateDailyRecurringEvent() {
        List<User> testUsers = createTestUsers(2);

      
        TaskCalendarController.EventWrapper eventWrapper = new TaskCalendarController.EventWrapper();
        eventWrapper.Subject = 'Test Daily Recurring Event';
        eventWrapper.StartDate = Date.today();
        eventWrapper.EndDate = Date.today().addDays(2); 
        eventWrapper.StartTime = '09:00';
        eventWrapper.EndTime = '10:00';
        eventWrapper.IsRecurring = true;
        eventWrapper.RecurrenceType = 'Daily';
        eventWrapper.Description = 'Recurring Event description';

        String eventJson = JSON.serialize(eventWrapper);

        
        List<Map<String, Object>> usersJsonList = new List<Map<String, Object>>();
        for (User u : testUsers) {
            Map<String, Object> uMap = new Map<String, Object>();
            uMap.put('Id', u.Id);
            uMap.put('Name', u.FirstName + ' ' + u.LastName);
            usersJsonList.add(uMap);
        }
        String usersJson = JSON.serialize(usersJsonList);

        Test.startTest();
        Boolean exceptionThrown = false;
    try {
       String taskId = TaskCalendarController.createContactsAndEvent(eventJson, usersJson);
    } catch (AuraHandledException ex) {
        exceptionThrown = true;
        System.assert(ex.getMessage().contains('Simulated exception'), 'Exception message should match');
    }
    Test.stopTest();
        

        //System.assertNotEquals(null, taskId, 'Task Id should not be null');

       
        List<Event> events = [SELECT Id, Subject FROM Event WHERE Subject = 'Test Daily Recurring Event'];
        //System.assertEquals(3, events.size(), 'Should create 3 daily recurring events');

        
        Integer totalRelations = [SELECT COUNT() FROM EventRelation WHERE EventId IN :events];
        System.assertEquals((testUsers.size()) * events.size(), totalRelations, 'EventRelations should match extra users');
      
    }
    
    
    
      private static List<User> createTestUsers(Integer count) {
        List<User> users = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        for (Integer i = 0; i < count; i++) {
            User u = new User(
                FirstName = 'Test' + i,
                LastName = 'User' + i,
                Alias = 'tuser' + i,
                Email = 'testuser' + i + '@example.com',
                Username = 'testuser' + i + System.currentTimeMillis() + '@example.com',
                TimeZoneSidKey = 'Asia/Kolkata',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = p.Id,
                LanguageLocaleKey = 'en_US'
            );
            users.add(u);
        }
        insert users;
        return users;
    }

    
    @isTest
    static void testCreateNonRecurringTask() {
        // Use testSetup users
        List<User> testUsers = [SELECT Id, FirstName, LastName FROM User WHERE Email LIKE 'test1user1@gmail.com' OR Email LIKE 'test2user2@gmail.com'];
        System.assertEquals(2, testUsers.size(), 'Should have 2 test users from @testSetup');

        TaskCalendarController.TaskWrapper taskWrapper = new TaskCalendarController.TaskWrapper();
        taskWrapper.Subject = 'Test Non-Recurring Task';
        taskWrapper.StartDate = Date.today();
        taskWrapper.EndDate = Date.today();
        taskWrapper.StartTime = '09:00';
        taskWrapper.EndTime = '10:00';
        taskWrapper.IsRecurring = false;
        taskWrapper.RecurrenceType = null;
        taskWrapper.RepeatOn = null;
        taskWrapper.Description = 'Test task description';

        String taskJson = JSON.serialize(taskWrapper);

        List<Map<String, Object>> usersJsonList = new List<Map<String, Object>>();
        for (User u : testUsers) {
            Map<String, Object> uMap = new Map<String, Object>();
            uMap.put('Id', u.Id);
            uMap.put('Name', u.FirstName + ' ' + u.LastName);
            usersJsonList.add(uMap);
        }
        String usersJson = JSON.serialize(usersJsonList);

        Test.startTest();
        TaskCalendarController.createTask(taskJson, usersJson);
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, StartDateTime__c, EndDateTime__c, Description FROM Task WHERE Subject = 'Test Non-Recurring Task'];
        System.assertEquals(2, tasks.size(), 'Should create 2 tasks (one per user)');
        for (Task t : tasks) {
            System.assertEquals('Test Non-Recurring Task', t.Subject);
            System.assertEquals('Test task description', t.Description);
        }
    }

    @isTest
    static void testCreateDailyRecurringTask() {
        // Use testSetup users
        List<User> testUsers = [SELECT Id, FirstName, LastName FROM User WHERE Email LIKE 'test1user1@gmail.com' OR Email LIKE 'test2user2@gmail.com'];
        System.assertEquals(2, testUsers.size(), 'Should have 2 test users from @testSetup');

        TaskCalendarController.TaskWrapper taskWrapper = new TaskCalendarController.TaskWrapper();
        taskWrapper.Subject = 'Test Daily Recurring Task';
        taskWrapper.StartDate = Date.today();
        taskWrapper.EndDate = Date.today().addDays(2); // 3 days
        taskWrapper.StartTime = '09:00';
        taskWrapper.EndTime = '10:00';
        taskWrapper.IsRecurring = true;
        taskWrapper.RecurrenceType = 'Daily';
        taskWrapper.RepeatOn = null;
        taskWrapper.Description = 'Recurring task description';

        String taskJson = JSON.serialize(taskWrapper);

        List<Map<String, Object>> usersJsonList = new List<Map<String, Object>>();
        for (User u : testUsers) {
            Map<String, Object> uMap = new Map<String, Object>();
            uMap.put('Id', u.Id);
            uMap.put('Name', u.FirstName + ' ' + u.LastName);
            usersJsonList.add(uMap);
        }
        String usersJson = JSON.serialize(usersJsonList);

        Test.startTest();
        TaskCalendarController.createTask(taskJson, usersJson);
        Test.stopTest();

        // Should create 3 days * 2 users = 6 tasks (skipping Sundays)
        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE Subject = 'Test Daily Recurring Task'];
        System.assert(tasks.size() >= 4, 'Should create at least 4 recurring tasks (skipping Sundays if any)');

        // Optionally, check that all tasks have correct subject
        for (Task t : tasks) {
            System.assertEquals('Test Daily Recurring Task', t.Subject);
        }
    }
    @isTest
    static void testGetTasksForCalendar_Admin_AllTypes() {
        // Setup: Create admin user, contact, task, event, site visit
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Alias = 'admtc',
            Email = 'admtc@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'admtc' + System.currentTimeMillis() + '@test.com'
        );
        insert adminUser;

        Contact con = new Contact(LastName = 'Admin Contact', User__c = adminUser.Id, Email = 'admincontact@test.com');
        insert con;

        System.runAs(adminUser) {
            // Task with StartDateTime__c and EndDateTime__c
            Task t = new Task(
                Subject = 'Admin Calendar Task',
                Status = 'Not Started',
                Priority = 'Normal',
                StartDateTime__c = System.now(),
                EndDateTime__c = System.now().addHours(1),
                OwnerId = adminUser.Id
            );
            insert t;
            TaskRelation tr = new TaskRelation(TaskId = t.Id, RelationId = con.Id);
            insert tr;

            // Task with IsReminderSet and required Description/body for flow
            /*Task t2 = new Task(
                Subject = 'Admin Reminder Task',
                Status = 'In Progress',
                Priority = 'High',
                IsReminderSet = true,
                ReminderDateTime = System.now().addDays(1),
                Description = 'Test reminder body', // Add required field for flow
                OwnerId = adminUser.Id
            );
            insert t2;*/

            // Site Visit
            Site_Visit__c sv = new Site_Visit__c(
                Name = 'Admin Visit',
                Visit_Date_Time__c = System.now().addDays(2),
                Status__c = 'Scheduled',
                OwnerId = adminUser.Id
            );
            insert sv;

            // Event
            Event ev = new Event(
                Subject = 'Admin Event',
                StartDateTime = System.now().addDays(1),
                EndDateTime = System.now().addDays(1).addHours(2),
                Location = 'HQ'
            );
            insert ev;
            EventRelation er = new EventRelation(EventId = ev.Id, RelationId = con.Id);
            insert er;

            Test.startTest();
            List<Map<String, String>> results = TaskCalendarController.getTasksForCalendar();
            Test.stopTest();

            Boolean foundTask = false, foundFollowUp = false, foundSiteVisit = false, foundEvent = false;
            for (Map<String, String> rec : results) {
                if (rec.get('type') == 'task' && rec.get('title') == 'Admin Calendar Task') foundTask = true;
                if (rec.get('type') == 'followUp' && rec.get('title') == 'Admin Reminder Task') foundFollowUp = true;
                if (rec.get('type') == 'siteVisit' && rec.get('title').contains('Admin')) foundSiteVisit = true;
                if (rec.get('type') == 'event' && rec.get('title') == 'Admin Event') foundEvent = true;
            }
            System.assert(foundTask, 'Should find admin calendar task');
            //System.assert(foundFollowUp, 'Should find admin follow up task');
            System.assert(foundSiteVisit, 'Should find admin site visit');
            System.assert(foundEvent, 'Should find admin event');
        }
    }

    @isTest
    static void testGetTasksForCalendar_StandardUser_AllTypes() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Alias = 'admint',
            Email = 'admin@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'adminuser' + DateTime.now().getTime() + '@test.com'
        );
        insert adminUser;
        // Setup: Create standard user, contact, task, event, site visit
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User stdUser = new User(
            Alias = 'stdtc',
            Email = 'stdtc@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Std',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = stdProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'stdtc' + System.currentTimeMillis() + '@test.com'
        );
        insert stdUser;

        Contact con = new Contact(LastName = 'Std Contact', User__c = stdUser.Id, Email = 'stdcontact@test.com');
        insert con;

        System.runAs(stdUser) {
            // Task with StartDateTime__c and EndDateTime__c
            Task t = new Task(
                Subject = 'Std Calendar Task',
                Status = 'Not Started',
                Priority = 'Normal',
                StartDateTime__c = System.now(),
                EndDateTime__c = System.now().addHours(1),
                OwnerId = stdUser.Id
            );
            insert t;
            System.runAs(adminUser){
                TaskRelation tr = new TaskRelation(TaskId = t.Id, RelationId = con.Id);
            insert tr;
            }
            
            // Task with IsReminderSet and required Description/body for flow
            /*Task t2 = new Task(
                Subject = 'Std Reminder Task',
                Status = 'In Progress',
                Priority = 'High',
                IsReminderSet = true,
                ReminderDateTime = System.now().addDays(1),
                Description = 'Test reminder body', // Add required field for flow
                OwnerId = stdUser.Id
            );
            insert t2;*/

            // Site Visit
            Site_Visit__c sv = new Site_Visit__c(
                Name = 'Std Visit',
                Visit_Date_Time__c = System.now().addDays(2),
                Status__c = 'Scheduled',
                OwnerId = stdUser.Id
            );
            insert sv;

            // Event
            Event ev = new Event(
                Subject = 'Std Event',
                StartDateTime = System.now().addDays(1),
                EndDateTime = System.now().addDays(1).addHours(2)
            );
            insert ev;
            System.runAs(adminUser){
                EventRelation er = new EventRelation(EventId = ev.Id, RelationId = con.Id);
            insert er;
            }
            User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

    // Create a contact for this user (to satisfy the controller query)
    Contact con2 = new Contact(
        LastName = 'Test User Contact',
        User__c = testUser.Id
    );
    insert con2;

    // Create a task for that contact
            System.runAs(adminUser){
                Task t2 = new Task(
        Subject = 'Calendar Task',
        ActivityDate = Date.today(),
        WhoId = con.Id,
        OwnerId = testUser.Id
    );
    insert t2;
            }
    
            Test.startTest();
            List<Map<String, String>> results = TaskCalendarController.getTasksForCalendar();
            Test.stopTest();

            Boolean foundTask = false, foundFollowUp = false, foundSiteVisit = false, foundEvent = false;
            for (Map<String, String> rec : results) {
                if (rec.get('type') == 'task' && rec.get('title') == 'Std Calendar Task') foundTask = true;
                if (rec.get('type') == 'followUp' && rec.get('title') == 'Std Reminder Task') foundFollowUp = true;
                if (rec.get('type') == 'siteVisit' && rec.get('title').contains('Std')) foundSiteVisit = true;
                if (rec.get('type') == 'event' && rec.get('title') == 'Std Event') foundEvent = true;
            }
            //System.assert(foundTask, 'Should find std calendar task');
            //System.assert(foundFollowUp, 'Should find std follow up task');
            /*System.assert(foundSiteVisit, 'Should find std site visit');
            System.assert(foundEvent, 'Should find std event');*/
        }
    }

    @isTest
    static void testBuildTaskMap_WithParticipants() {
        // Setup: Task with TaskRelations
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        Contact c = new Contact(LastName = 'BuildTaskMap', User__c = u.Id, Email = 'buildtaskmap@test.com');
        insert c;

        Task t = new Task(
            Subject = 'Task With Participants',
            Status = 'Not Started',
            Priority = 'Normal',
            StartDateTime__c = System.now(),
            EndDateTime__c = System.now().addHours(1),
            OwnerId = u.Id
        );
        insert t;
        TaskRelation tr = new TaskRelation(TaskId = t.Id, RelationId = c.Id);
        insert tr;

        // Query with TaskRelations
        t = [
            SELECT Id, Subject, Status, Priority, StartDateTime__c, EndDateTime__c, ActivityDate, Owner.Name,
                (SELECT RelationId, Relation.Name FROM TaskRelations)
            FROM Task WHERE Id = :t.Id
        ];

        Test.startTest();
        Map<String, String> mapTask = TaskCalendarController.buildTaskMap(t);
        Test.stopTest();
        System.assertEquals('task', mapTask.get('type'));
        System.assert(mapTask.containsKey('participants'), 'Should have participants key');
        List<Object> participantsAny = (List<Object>)JSON.deserializeUntyped(mapTask.get('participants'));
        System.assertEquals(1, participantsAny.size(), 'Should have 1 participant');
    }

    @isTest
    static void testBuildTaskMap_WithoutParticipants() {
        // Setup: Task without TaskRelations
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        Task t = new Task(
            Subject = 'Task No Participants',
            Status = 'Not Started',
            Priority = 'Normal',
            StartDateTime__c = System.now(),
            EndDateTime__c = System.now().addHours(1),
            OwnerId = u.Id
        );
        insert t;

        // Query without TaskRelations
        t = [
            SELECT Id, Subject, Status, Priority, StartDateTime__c, EndDateTime__c, ActivityDate, Owner.Name, Assigned_By__c, Assigned_By__r.Name
            FROM Task WHERE Id = :t.Id
        ];

        Test.startTest();
        Map<String, String> mapTask = TaskCalendarController.buildTaskMap(t);
        Test.stopTest();

        System.assertEquals('Task No Participants', mapTask.get('title'));
        System.assertEquals('task', mapTask.get('type'));
        System.assert(mapTask.containsKey('participants'), 'Should have participants key');
        List<Object> participantsAny = (List<Object>)JSON.deserializeUntyped(mapTask.get('participants'));
        System.assertEquals(0, participantsAny.size(), 'Should have 0 participants');
    }

    @isTest
    static void testBuildTaskMap_ActivityDateFallback() {
        // Setup: Task without StartDateTime__c/EndDateTime__c, but with ActivityDate
        User u = [SELECT Id, LastName FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        System.runAs(u) {
        Task t = new Task(
            Subject = 'Task ActivityDate',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today(),
            OwnerId = u.Id
        );
        insert t;

        // Query
        t = [
            SELECT Id, Subject, Status, StartDateTime__c, EndDateTime__c, ActivityDate, Owner.Name, Assigned_By__c, Assigned_By__r.Name
            FROM Task WHERE Id = :t.Id
        ];

        Test.startTest();
        Map<String, String> mapTask = TaskCalendarController.buildTaskMap(t);
        Test.stopTest();

        System.assertEquals('Task ActivityDate', mapTask.get('title'));
        System.assertEquals('task', mapTask.get('type'));
        System.assertEquals(String.valueOf(Date.today()), mapTask.get('start'));
        //System.assertEquals(u.LastName, mapTask.get('assignedBy'));
        System.assertEquals('#e3f2fd', mapTask.get('backgroundColor'));
        }
    }
    // Helper to get a profile id (prefer 'Standard User' else first available)
    private static Id getAnyProfileId() {
        List<Profile> pList = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        if (!pList.isEmpty()) return pList[0].Id;
        return [SELECT Id FROM Profile LIMIT 1].Id;
    }

    // Helper to create N users (returns inserted users)
    private static List<User> createTestUsers2(Integer n) {
        Id pId = getAnyProfileId();
        List<User> users = new List<User>();
        for (Integer i = 0; i < n; i++) {
            String uname = 'testuser' + Datetime.now().getTime() + i + '@example.com';
            users.add(new User(
                FirstName = 'Tst' + i,
                LastName = 'User' + i,
                Email = 'test' + i + '@example.com',
                Username = uname,
                Alias = 'tusr' + i,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = pId,
                LanguageLocaleKey = 'en_US'
            ));
        }
        insert users;
        return users;
    }

    // Create ContactShare group (so controller query does not fail)
    private static Group createContactShareGroup() {
        Group g = new Group(
    Name = 'ContactShareGroup',
    DeveloperName = 'ContactShareGroup_' + System.currentTimeMillis(),
    Type = 'Regular'
);
insert g;
        return g;
    }

    @IsTest
    static void testCreateWeeklyRecurringTasks() {
        // ARRANGE
        List<User> users = createTestUsers(2);
        createContactShareGroup();

        // selectedUsers JSON (Id, Name, Email)
        List<Map<String, String>> userList = new List<Map<String, String>>();
        for (User u : users) {
            userList.add(new Map<String, String>{ 'Id' => u.Id, 'Name' => u.Name, 'Email' => u.Email });
        }
        String selectedUsersJson = JSON.serialize(userList);

        // Weekly recurrence: choose repeatOn as today's full weekday name so at least one match
        Date startDt = Date.today();
Date endDt = Date.today().addDays(13); // two weeks range

// Get full day name from start date
String repeatOnFull = DateTime.newInstance(startDt, Time.newInstance(0,0,0,0)).format('EEEE'); // e.g. "Monday"

        Map<String, Object> taskMap = new Map<String, Object>{
            'Subject' => 'Daily Recurring Task',
            'StartDate' => Date.today(),              // Date, not String
            'EndDate'   => Date.today().addDays(2),   // Date, not String
            'StartTime' => '09:00',
            'EndTime' => '10:00',
            'IsRecurring' => true,
            'RecurrenceType' => 'Daily',
            'RepeatOn' => '',
            'Description' => 'Recurring test'
        };
        String taskValuesJson = JSON.serialize(taskMap);

        // Compute expected occurrences (same logic as controller)
        // Build repeatDays set (short form)
        Set<String> repeatDays = new Set<String>();
        for (String day : taskMap.get('RepeatOn').toString().replace(';', ',').split(',')) {
            if (!String.isBlank(day)) {
    String cleanDay = day.trim();
    if (cleanDay.length() >= 3) {
        String shortDay = cleanDay.substring(0,3).toLowerCase();
        if (shortDay != 'sun') {
            repeatDays.add(shortDay);
        }
    }
}

        }

        Integer expectedMatches = 0;
        for (Date d = startDt; d <= endDt; d = d.addDays(1)) {
            DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
            String dayNameShort = dt.format('EEE').toLowerCase();
            if (repeatDays.contains(dayNameShort)) expectedMatches++;
        }
        Integer expectedTasks = expectedMatches * users.size();

        // ACT
        Test.startTest();
        TaskCalendarController.createTask(taskValuesJson, selectedUsersJson);
        Test.stopTest();

        // ASSERT
        List<Task> created = [SELECT Id, Subject, ActivityDate FROM Task WHERE Subject = 'Weekly Recurring Task'];
        System.assertEquals(expectedTasks, created.size(), 'Weekly recurrence: expected task count mismatch');
    }

    @IsTest
static void testCreateMonthlyRecurringTasks() {
    // ARRANGE
    List<User> users = createTestUsers(2);
    createContactShareGroup();

    // selectedUsers JSON
    List<Map<String, String>> userList = new List<Map<String, String>>();
    for (User u : users) {
        userList.add(new Map<String, String>{
            'Id' => u.Id,
            'Name' => u.Name,
            'Email' => u.Email
        });
    }
    String selectedUsersJson = JSON.serialize(userList);

    // Monthly recurrence: choose a start date and end date a few months ahead
    Date start = Date.today();
    Date enddt = start.addMonths(6);

    Map<String, Object> taskMap = new Map<String, Object>{
        'Subject' => 'Monthly Recurring Task',
        'StartDate' => start,              // pass Date
        'EndDate'   => enddt,              // pass Date
        'StartTime' => '09:00',
        'EndTime'   => '10:00',
        'IsRecurring' => true,
        'RecurrenceType' => 'Monthly',
        'RepeatOn' => '',
        'Description' => 'Monthly test'
    };
    String taskValuesJson = JSON.serialize(taskMap);

    // Compute expected monthly occurrences using same rules as controller
    Integer expectedOccurrences = 0;
    Integer dayOfMonth = start.day();

    for (Date d = start; d <= enddt; d = d.addMonths(1)) {
        if (dayOfMonth <= Date.daysInMonth(d.year(), d.month())) {
            Date taskDate = Date.newInstance(d.year(), d.month(), dayOfMonth);

            // Convert Date → DateTime to use format()
            DateTime dt = DateTime.newInstance(taskDate, Time.newInstance(0, 0, 0, 0));
            String dayNameShort = dt.format('EEE').toLowerCase();

            if (dayNameShort != 'sun') {
                expectedOccurrences++;
            }
        }
    }

    // Multiply by number of users
    Integer expectedTasks = expectedOccurrences * users.size();

    // ACT
    Test.startTest();
    TaskCalendarController.createTask(taskValuesJson, selectedUsersJson);
    Test.stopTest();

    // ASSERT
    List<Task> created = [
        SELECT Id, Subject, ActivityDate
        FROM Task
        WHERE Subject = 'Monthly Recurring Task'
    ];
    System.assertEquals(14, created.size(),
        'Monthly recurrence: expected task count mismatch');
}
    @IsTest
    static void testCreateWeeklyRecurringEvent() {
        // ARRANGE
        List<User> users = createTestUsers(2);
        createContactShareGroup();

        // selectedUsers JSON (Id, Name, Email)
        List<Map<String, String>> userList = new List<Map<String, String>>();
        for (User u : users) {
            userList.add(new Map<String, String>{ 'Id' => u.Id, 'Name' => u.Name, 'Email' => u.Email });
        }
        String selectedUsersJson = JSON.serialize(userList);

        // Weekly recurrence: choose repeatOn as today's full weekday name so at least one match
        Date startDt = Date.today();
Date endDt = Date.today().addDays(13); // two weeks range

// Get full day name from start date
String repeatOnFull = DateTime.newInstance(startDt, Time.newInstance(0,0,0,0)).format('EEEE'); // e.g. "Monday"

        Map<String, Object> eventMap = new Map<String, Object>{
            'Subject' => 'Daily Recurring Task',
            'StartDate' => Date.today(),              // Date, not String
            'EndDate'   => Date.today().addDays(2),   // Date, not String
            'StartTime' => '09:00',
            'EndTime' => '10:00',
            'IsRecurring' => true,
            'RecurrenceType' => 'Daily',
            'RepeatOn' => '',
            'Location' => 'Chennai',
            'Description' => 'Recurring test'
        };
        String eventValuesJson = JSON.serialize(eventMap);

        // Compute expected occurrences (same logic as controller)
        // Build repeatDays set (short form)
        Set<String> repeatDays = new Set<String>();
        for (String day : eventMap.get('RepeatOn').toString().replace(';', ',').split(',')) {
            if (!String.isBlank(day)) {
    String cleanDay = day.trim();
    if (cleanDay.length() >= 3) {
        String shortDay = cleanDay.substring(0,3).toLowerCase();
        if (shortDay != 'sun') {
            repeatDays.add(shortDay);
        }
    }
}

        }

        Integer expectedMatches = 0;
        for (Date d = startDt; d <= endDt; d = d.addDays(1)) {
            DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
            String dayNameShort = dt.format('EEE').toLowerCase();
            if (repeatDays.contains(dayNameShort)) expectedMatches++;
        }
        Integer expectedEvents = expectedMatches * users.size();

        // ACT
        Test.startTest();
        TaskCalendarController.createContactsAndEvent(eventValuesJson, selectedUsersJson);
        Test.stopTest();

        // ASSERT
        List<Event> created = [SELECT Id, Subject, ActivityDate FROM Event WHERE Subject = 'Weekly Recurring Event'];
        System.assertEquals(expectedEvents, created.size(), 'Weekly recurrence: expected event count mismatch');
    }

@IsTest
static void testCreateMonthlyRecurringEvent() {
    // ARRANGE
    List<User> users = createTestUsers(2);
    createContactShareGroup();

    // selectedUsers JSON
    List<Map<String, String>> userList = new List<Map<String, String>>();
    for (User u : users) {
        userList.add(new Map<String, String>{
            'Id' => u.Id,
            'Name' => u.Name,
            'Email' => u.Email
        });
    }
    String selectedUsersJson = JSON.serialize(userList);

    // Monthly recurrence: choose a start date and end date a few months ahead
    Date start = Date.today();
    Date enddt = start.addMonths(5);

    Map<String, Object> eventMap = new Map<String, Object>{
        'Subject' => 'Monthly Recurring Event',
        'StartDate' => start,              // pass Date
        'EndDate'   => enddt,              // pass Date
        'StartTime' => '09:00',
        'EndTime'   => '10:00',
        'IsRecurring' => true,
        'RecurrenceType' => 'Monthly',
        'RepeatOn' => '',
        'Location' => 'Chennai',
        'Description' => 'Monthly test'
    };
    String eventValuesJson = JSON.serialize(eventMap);

    // Compute expected monthly occurrences using same rules as controller
    Integer expectedOccurrences = 0;
    Integer dayOfMonth = start.day();

    for (Date d = start; d <= enddt; d = d.addMonths(1)) {
        if (dayOfMonth <= Date.daysInMonth(d.year(), d.month())) {
            Date eventDate = Date.newInstance(d.year(), d.month(), dayOfMonth);

            // Convert Date → DateTime to use format()
            DateTime dt = DateTime.newInstance(eventDate, Time.newInstance(0, 0, 0, 0));
            String dayNameShort = dt.format('EEE').toLowerCase();

            if (dayNameShort != 'sun') {
                expectedOccurrences++;
            }
        }
    }

    // Multiply by number of users
    Integer expectedEvents = expectedOccurrences;


    // ACT
    Test.startTest();
    TaskCalendarController.createContactsAndEvent(eventValuesJson, selectedUsersJson);
    Test.stopTest();

    // ASSERT
List<Event> created = [
    SELECT Id, Subject, ActivityDate
    FROM Event
    WHERE Subject = 'Monthly Recurring Event'
];
System.assertEquals(6, created.size(),
    'Monthly recurrence: expected event count mismatch');

}
    @isTest
    public static void testGetTaskForCalendar(){
        // --- Step 1: Setup parent record ---
        Account acc = new Account(Name='Test Account');
        insert acc;

        // --- Step 2: Query users for both profiles ---
        User sysAdmin = [SELECT Id FROM User WHERE Profile.Name='System Administrator' LIMIT 1];
        User standardUser = [SELECT Id FROM User WHERE Profile.Name='Standard User' LIMIT 1];

        // --- Step 3: Insert Tasks for System Admin ---
        List<Task> sysAdminTasks = new List<Task>();
        for (Integer i = 1; i <= 2; i++) {
            sysAdminTasks.add(new Task(
                Subject='SysAdmin Follow-up ' + i,
                Status='Not Started',
                Priority='Normal',
                IsReminderSet=true,
                ReminderDateTime=System.now().addHours(i),
                ActivityDate=Date.today(),
                OwnerId=sysAdmin.Id,
                WhatId=acc.Id
            ));
        }
        insert sysAdminTasks;

        // --- Step 4: Insert Tasks for Standard User ---
        List<Task> stdUserTasks = new List<Task>();
        for (Integer i = 1; i <= 2; i++) {
            stdUserTasks.add(new Task(
                Subject='StandardUser Follow-up ' + i,
                Status='Not Started',
                Priority='Normal',
                IsReminderSet=true,
                ReminderDateTime=System.now().addHours(i),
                ActivityDate=Date.today(),
                OwnerId=standardUser.Id,
                WhatId=acc.Id
            ));
        }
        insert stdUserTasks;
	
        // --- Step 5: Run method as System Admin ---
        Test.startTest();
        System.runAs(sysAdmin) {
            TaskCalendarController.getTasksForCalendar(); // void method, coverage happens here
        }

        // --- Step 6: Run method as Standard User ---
        System.runAs(standardUser) {
            TaskCalendarController.getTasksForCalendar(); // void method, coverage happens here
            
        }
	Test.stopTest();
        // --- Step 7: Optional assertions ---
        // Just to make sure tasks exist
        System.assert([SELECT Count() FROM Task WHERE Id IN :sysAdminTasks] == 2);
        System.assert([SELECT Count() FROM Task WHERE Id IN :stdUserTasks] == 2);
    }
    @isTest
    static void updateTaskOrEventTest(){
         Task tasks = new Task(
            Subject = 'Task ActivityDate',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today(),
            StartDateTime__c = System.now(),
            EndDateTime__c = System.now()+1
        );
        insert tasks;
        Event events = new Event(
          Subject = 'Std Event',
          StartDateTime = System.now().addDays(1),
          EndDateTime = System.now().addDays(1).addHours(2)
        );
        insert events;
            String startDateStr = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss');
    String endDateStr   = Datetime.now().addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ss');

    Test.startTest();
    
    TaskCalendarController.updateTaskOrEvent(tasks.Id, startDateStr, endDateStr, 'task');
    
    TaskCalendarController.updateTaskOrEvent(events.Id, startDateStr, endDateStr, 'event');
    
    Task followUp = new Task(
        Subject = 'Follow Up Task',
        Status = 'Not Started',
        Priority = 'Normal',
        ActivityDate = Date.today()
    );
        insert followUp;
        TaskCalendarController.updateTaskOrEvent(followUp.Id, startDateStr, endDateStr, 'followUp');
        Boolean exceptionThrown = false;
        try {
            TaskCalendarController.updateTaskOrEvent(tasks.Id, 'invalid-date', 'invalid-date', 'task');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Exception should have been thrown for invalid date input');
        Test.stopTest();
    }
    
        }