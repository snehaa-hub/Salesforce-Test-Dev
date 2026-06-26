@isTest
public class AWH_EmployeeTrackerControllerTest {

    @testSetup
    static void setupData() {
        // Create a User record
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        datetime dt = datetime.now();
        String uniqueUserName = 'testuser' + dt.getTime() + '@example.com';
		Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test45',
            LastName = 'User12',
            Email = 'testuser1234@example.com',
            Username = uniqueUserName,
            Alias = 'tuser1',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = sysAdminProfile.Id
        );
        insert testUser;
        
        Event testEvent = new Event(
        Subject = 'Test Event',
        StartDateTime = System.now(),
        EndDateTime = System.now().addHours(1)
    );
    insert testEvent;
    
    EventRelation testEventRelation = new EventRelation(
        EventId = testEvent.Id,
        RelationId = testUser.Id
    );
    insert testEventRelation;
     


        // Create a sample Employee_Time_Sheet__c record
        Employee_Time_Sheet__c empSheet = new Employee_Time_Sheet__c(
            Employee__c = testUser.Id,
            Entry_Type__c = 'In Office',
            Date__c = Date.today(),
            Time_In__c = Datetime.now().time()
        );
        insert empSheet;
        Employee_Time_Sheet_Line_Item__c empli =new Employee_Time_Sheet_Line_Item__c();
        empli.Employee_Time_Sheet__c = empSheet.Id;
        empli.Check_In_Km__c = 12345;
        empli.Check_Out_Km__c = 13245;
        empli.Time_In__c = Datetime.now().time();
        insert empli;
        
         Contact con = new Contact(LastName = 'Test Contact',User__c=UserInfo.getUserId());
        insert con;
        
        Task testTask = new Task(
            Subject = 'Test Task',
            OwnerId = UserInfo.getUserId(),
            Assigned_By__c = UserInfo.getUserId(),
            EndDateTime__c = System.now().addHours(1),
            Status = 'Not Started',
            Priority = 'Normal'
        );
        insert testTask;
        
         TaskRelation tr = new TaskRelation(
                TaskId = testTask.Id,
                RelationId = con.Id
            );
            insert tr;

       
        Site_Visit__c visit1 = new Site_Visit__c(
            Name = 'Visit Admin',
            Visit_Date_Time__c = Date.today().addDays(2),
            Status__c = 'Scheduled',
            OwnerId = UserInfo.getUserId()
        );
        insert visit1;

            Site_Visit__c visit2 = new Site_Visit__c(
            Name = 'Visit Admin',
            Visit_Date_Time__c = Date.today().addDays(2),
            Status__c = 'Completed',
            OwnerId = UserInfo.getUserId()
        );
        insert visit2;

         Site_Visit__c visit3 = new Site_Visit__c(
            Name = 'Visit Admin',
            Visit_Date_Time__c = System.now().addHours(2),
            Status__c = 'Rescheduled',
            OwnerId = UserInfo.getUserId()
        );
        insert visit3;

         Site_Visit__c visit4 = new Site_Visit__c(
            Name = 'Visit Admin',
            Visit_Date_Time__c = Date.today().addDays(2),
            Status__c = 'Cancelled',
            OwnerId = UserInfo.getUserId()
        );
        insert visit4;

       
        Site_Visit__c visit5 = new Site_Visit__c(
            Name = 'Visit Normal',
            Visit_Date_Time__c = Date.today().addDays(3),
            Status__c = 'Scheduled',
            OwnerId = UserInfo.getUserId()
        );
        insert visit5;

        

         Site_Visit__c visit6 = new Site_Visit__c(
            Name = 'Visit Normal',
            Visit_Date_Time__c = Date.today().addDays(3),
            Status__c = 'Completed',
            OwnerId = UserInfo.getUserId()
        );
        insert visit6;

        Site_Visit__c visit7 = new Site_Visit__c(
            Name = 'Visit Normal',
            Visit_Date_Time__c = Date.today().addDays(3),
            Status__c = 'Rescheduled',
            OwnerId = UserInfo.getUserId()
        );
        insert visit7;

        Site_Visit__c visit8 = new Site_Visit__c(
            Name = 'Visit Normal',
            Visit_Date_Time__c = Date.today().addDays(3),
            Status__c = 'Cancelled',
            OwnerId = UserInfo.getUserId()
        );
        insert visit8;
        Employee_Leave_Sheet__c leave = new Employee_Leave_Sheet__c(
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(1),
            Leave_Type__c = 'SL',
            Reason__c = 'Headache'
        );
        Insert leave;
    }

    @isTest
    static void testUserdetails() {
        User u = [SELECT Id FROM User LIMIT 1];
        List<User> result = AWH_EmployeeTrackerController.userdetails(u.Id);

        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(u.Id, result[0].Id);
    }

    @isTest
    static void testSaveLeave() {
        Employee_Leave_Sheet__c leave = new Employee_Leave_Sheet__c(
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(1),
            Leave_Type__c = 'SL',
            Reason__c = 'Headache'
        );
        Test.startTest();
        String result = AWH_EmployeeTrackerController.saveLeave(leave);
        Test.stopTest();
        System.assertEquals('SUCCESS', result);
    }
     @isTest
    static void testUpdateLeave() {
        Employee_Leave_Sheet__c leave = [SELECT Id FROM Employee_Leave_Sheet__c LIMIT 1];
        leave.Leave_Status__c = 'Approved';
        leave.Comment__c = 'Approved by Manager';
        Test.startTest();
        String result = AWH_EmployeeTrackerController.updateLeave(leave);
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetMyLeaves() {
        Test.startTest();
        List<Employee_Leave_Sheet__c> myLeaves = AWH_EmployeeTrackerController.getMyLeaves();
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetAllLeaves() {
        Test.startTest();
        List<Employee_Leave_Sheet__c> allLeaves = AWH_EmployeeTrackerController.getAllLeaves();
        Test.stopTest();
        
    }

    @isTest
    static void testGetempcheckInRecords() {
        User u = [SELECT Id FROM User LIMIT 1];
        Date testDate = Date.today().addDays(-1); // Ensure records created today will be returned

        List<Employee_Time_Sheet__c> records = AWH_EmployeeTrackerController.getempcheckInRecords(u.Id, testDate);
        List<Employee_Time_Sheet__c> etsrecords =[Select Id from Employee_Time_Sheet__c Limit 1];
		List<Employee_Time_Sheet_Line_Item__c> recordsli = AWH_EmployeeTrackerController.getempLineItem(etsrecords[0].Id);
        System.assertNotEquals(null, records);
       // System.assert(records.size() > 0, 'Expected at least one record');
       // System.assertEquals(u.Id, records[0].Employee__c);
    }
    @isTest
    static void testCreateAttachment() {
        Employee_Time_Sheet__c u = [SELECT Id FROM Employee_Time_Sheet__c LIMIT 1];
      
         String base64Prefix = 'data:image/png;base64,';
        String dummyBase64Image = base64Prefix +
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y+RUIYAAAAASUVORK5CYII=';

        AWH_EmployeeTrackerController.saveSiteVisitImage(dummyBase64Image,u.Id, 'Test attachment');

       // System.assert(records.size() > 0, 'Expected at least one record');
       // System.assertEquals(u.Id, records[0].Employee__c);
    }
     @isTest
    static void testgetTaskAndSiteVisit() {
       AWH_EmployeeTrackerController.getTaskItem();

       // System.assert(records.size() > 0, 'Expected at least one record');
       // System.assertEquals(u.Id, records[0].Employee__c);
    }
    @isTest
    static void testBuildEventMap() {
        // Create test data
       Event testEvent =[SELECT Id, Subject, StartDateTime, EndDateTime, Location,OwnerId,
           (SELECT RelationId, Relation.Name FROM EventRelations)
    FROM Event];

        Test.startTest();
        Map<String, Object> result = AWH_EmployeeTrackerController.buildEventMap(testEvent);
        Test.stopTest();

       
    }

    @isTest
    static void testBuildProfileSiteVisitMap() {
         // Create Account
		 RecordType rc = [SELECT Id, Name, DeveloperName, SObjectType 
FROM RecordType 
WHERE SObjectType = 'Account' 
AND DeveloperName = 'PersonAccount'];
		 Account acc = new Account(LastName='Test Name',RecordTypeId = rc.Id);
        insert acc;
	Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Enquiry__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }
    // Create Enquiry__c with the RecordType
    Enquiry__c enquiry = new Enquiry__c(
        Name = 'Test Enquiry',
        RecordTypeId = rtMap.get('Landlord'),
        Status__c = 'New', 
    	Email__c = 'test@example.com',
        Contact_Person__c = acc.Id,
        Mobile__c='1234567890'
    );
    insert enquiry;
        // Create test opportunity
         Opportunity__c opp = new Opportunity__c(
        Name = 'Test Opportunity',
        Property_Type__c = 'Leasing',
        Account_Name__c = acc.Id,
        Enquiry__c = enquiry.Id,
        Share_Location__c = true,
        Landlord_Name__c = true,
        Landlord_Mobile__c = true
    );
    insert opp;

        // Create test site visit
        Site_Visit__c sv = new Site_Visit__c(
            Name = 'Visit Admin',
            Opportunity__c = opp.Id,
            Visit_Date_Time__c = System.now().addhours(1),
            Status__c = 'Scheduled',
            OwnerId = UserInfo.getUserId()
        );
        insert sv;
        Test.startTest();
        Map<String, Object> result = AWH_EmployeeTrackerController.buildProfileSiteVisitMap(sv);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('utility:target', result.get('iconName'));
    }

    @isTest
    static void testGetLeaveCount() {
        // Create test leave record for today
        Employee_Leave_Sheet__c leave = new Employee_Leave_Sheet__c(
            Employee__c = UserInfo.getUserId(),
            Start_Date__c = System.today(),
            End_Date__c = System.today().addDays(1),
            Leave_Type__c = 'SL',
            Leave_Status__c = 'Approved',
            Is_Half_Day__c = false
        );
        insert leave;

        Test.startTest();
        Boolean hasLeave = AWH_EmployeeTrackerController.getLeaveCount();
        Test.stopTest();

        System.assertEquals(true, hasLeave, 'Should return true as there is an approved leave for today');
    }

    @isTest
    static void testGetLeaveCountNoLeave() {
        Test.startTest();
        Boolean hasLeave = AWH_EmployeeTrackerController.getLeaveCount();
        Test.stopTest();

        System.assertEquals(false, hasLeave, 'Should return false as there is no approved leave for today');
    }

    @isTest
    static void testUpdateLeaveCancelled() {
        Employee_Leave_Sheet__c leave = [SELECT Id FROM Employee_Leave_Sheet__c LIMIT 1];
        leave.Leave_Status__c = 'Cancelled';
        
        Test.startTest();
        String result = AWH_EmployeeTrackerController.updateLeave(leave);
        Test.stopTest();
        
        
    }
}