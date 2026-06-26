public with sharing class TaskCalendarController {
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getTasksForCalendar() {
        List<Map<String, String>> taskList = new List<Map<String, String>>();
        Id currentUserId = UserInfo.getUserId();
        String currentUsername = UserInfo.getUserName();
        List<Contact> conList = [
            SELECT Id 
            FROM Contact 
            WHERE User__c = :currentUserId 
            LIMIT 1
        ];

        Id contactId;
        if (!conList.isEmpty()) {
            contactId = conList[0].Id;
        }

        String profileName = [
            SELECT Profile.Name FROM User WHERE Id = :currentUserId
        ].Profile.Name;
        
        
        if (profileName == 'System Administrator') {
            for (Task t : [
            //CHANGED: Added WhatId and Status to SELECT for color logic.
            SELECT Id, Subject, Status, Priority, WhatId,
                StartDateTime__c, EndDateTime__c, Due_Date_Time__c, Assigned_By__r.Name, ActivityDate,
                Owner.Name,
                (SELECT Relation.Name FROM TaskRelations)
            FROM Task
            ]) {
                taskList.add(buildTaskMap(t));
            }
            for (Task t : [
            SELECT Id, Subject, Status, Priority, WhatId, What.Name, IsReminderSet, ReminderDateTime,
                StartDateTime__c, EndDateTime__c, Due_Date_Time__c,
                Assigned_By__r.Name, ActivityDate, Owner.Name
            FROM Task WHERE ReminderDateTime != NULL AND WhatId != NULL
        ]) {
            Map<String, String> followUpTask = new Map<String, String>();
            followUpTask.put('id', t.Id);
            followUpTask.put('title', t.Subject);
            followUpTask.put('reminderDateTime', String.valueOf(t.ReminderDateTime));
            followUpTask.put('relatedTo', t.What != null ? t.What.Name : '');
            followUpTask.put('status', t.Status);
            followUpTask.put('priority', t.Priority);
            followUpTask.put('type', 'followUp');
            followUpTask.put('Owner', t.Owner.Name);

            Date today = Date.today();

            if (t.ActivityDate != null && t.ActivityDate < today && t.Status != 'Completed') {
                followUpTask.put('backgroundColor', '#ffcdd2');
                followUpTask.put('borderColor', '#d32f2f');
                followUpTask.put('textColor', '#b71c1c');
            } else if (t.Status == 'Completed') {
                followUpTask.put('backgroundColor', '#e8f5e9');
                followUpTask.put('borderColor', '#43a047');
                followUpTask.put('textColor', '#1b5e20');
            } else {
                followUpTask.put('backgroundColor', '#fffde7');
                followUpTask.put('borderColor', '#ffd600');
                followUpTask.put('textColor', '#ff6f00');
            }
            taskList.add(followUpTask);
        }
            for (Site_Visit__c sv : [
                SELECT Id, Name, Visit_Date__c, Visit_Date_Time__c, Status__c, OwnerId, Owner.Name, Opportunity__r.Name
                FROM Site_Visit__c 
                WHERE Visit_Date__c != NULL
            ]) {
                taskList.add(buildSiteVisitMap(sv));
            }

            for (Event ev : [
                SELECT Id, Subject, StartDateTime, EndDateTime, Location,
                       (SELECT RelationId, Relation.Name FROM EventRelations)
                FROM Event
            ]) {
                Map<String, String> eventMap = new Map<String, String>();
                eventMap.put('id', ev.Id);
                eventMap.put('title', ev.Subject);
                eventMap.put('start', String.valueOf(ev.StartDateTime));
                eventMap.put('end', String.valueOf(ev.EndDateTime));
                eventMap.put('type', 'event');
                eventMap.put('location', ev.Location);
                eventMap.put('backgroundColor', '#e6ceecff');
                eventMap.put('borderColor', '#e51fecff');
                eventMap.put('textColor', '#1d0910ff');

                List<String> participantNames = new List<String>();
                for (EventRelation er : ev.EventRelations) {
                    if (er.Relation != null) {
                        participantNames.add(er.Relation.Name);
                    }
                }
                eventMap.put('participants', JSON.serialize(participantNames));
                taskList.add(eventMap);
            }
            
        } else {
            for (Task t : [
            // CHANGED: Added WhatId and Status to SELECT for color logic 
            SELECT Id, Subject, Status, Priority, WhatId,
                StartDateTime__c, EndDateTime__c, Due_Date_Time__c,
                Assigned_By__r.Name, ActivityDate, Owner.Name,
                (SELECT RelationId, Relation.Name FROM TaskRelations WHERE Relation.Type = 'Contact')
            FROM Task
            WHERE Id IN (
                SELECT TaskId FROM TaskRelation WHERE RelationId = :contactId
            )
            ]) {
                taskList.add(buildTaskMap(t));
            }

            for (Task t : [
                SELECT Id, Subject, Status, Priority, WhatId, What.Name, IsReminderSet, ReminderDateTime,
                    StartDateTime__c, EndDateTime__c, Due_Date_Time__c,
                    Assigned_By__r.Name, ActivityDate, Owner.Name
                FROM Task
                WHERE ReminderDateTime != NULL AND OwnerId = :currentUserId AND WhatId != NULL
            ]) {
                Map<String, String> followUpTask = new Map<String, String>();
                followUpTask.put('id', t.Id);
                followUpTask.put('title', t.Subject);
                followUpTask.put('reminderDateTime', String.valueOf(t.ReminderDateTime));
                followUpTask.put('relatedTo', t.What != null ? t.What.Name : '');
                followUpTask.put('status', t.Status);
                followUpTask.put('priority', t.Priority);
                followUpTask.put('type', 'followUp');
                followUpTask.put('Owner', t.Owner.Name);

                Date today = Date.today();

                if (t.ActivityDate != null && t.ActivityDate < today && t.Status != 'Completed') {
                    followUpTask.put('backgroundColor', '#ffcdd2');
                    followUpTask.put('borderColor', '#d32f2f');
                    followUpTask.put('textColor', '#b71c1c');
                } else if (t.Status == 'Completed') {
                    followUpTask.put('backgroundColor', '#e8f5e9');
                    followUpTask.put('borderColor', '#43a047');
                    followUpTask.put('textColor', '#1b5e20');
                } else {
                    followUpTask.put('backgroundColor', '#fffde7');
                    followUpTask.put('borderColor', '#ffd600');
                    followUpTask.put('textColor', '#ff6f00');
                }
                taskList.add(followUpTask);
            }

            for (Event ev : [
                SELECT Id, Subject, StartDateTime, EndDateTime,
                       (SELECT RelationId, Relation.Name FROM EventRelations WHERE Relation.Type = 'Contact')
                FROM Event WHERE Id IN (
                    SELECT EventId FROM EventRelation WHERE RelationId = :contactId
                )
            ]) {
                Map<String, String> eventMap = new Map<String, String>();
                eventMap.put('id', ev.Id);
                eventMap.put('title', ev.Subject);
                eventMap.put('start', String.valueOf(ev.StartDateTime));
                eventMap.put('end', String.valueOf(ev.EndDateTime));
                eventMap.put('type', 'event');
                eventMap.put('backgroundColor', '#e6ceecff');
                eventMap.put('borderColor', '#e51fecff');
                eventMap.put('textColor', '#1d0910ff');

                List<String> participantNames = new List<String>();
                for (EventRelation er : ev.EventRelations) {
                    if (er.Relation != null) {
                        participantNames.add(er.Relation.Name);
                    }
                }
                eventMap.put('participants', JSON.serialize(participantNames));
                taskList.add(eventMap);
            }

            for (Site_Visit__c sv : [
                SELECT Id, Name, Visit_Date__c, Visit_Date_Time__c, Status__c, OwnerId, Owner.Name, Opportunity__r.Name
                FROM Site_Visit__c 
                WHERE Visit_Date__c != NULL AND OwnerId = :currentUserId
            ]) {
                taskList.add(buildProfileSiteVisitMap(sv));
            }
        }
        return taskList;
    }
    
    
    // Task colors
    private static final String TASK_BG_COLOR     = '#e3f2fd';
    private static final String TASK_BORDER_COLOR = '#2196f3';
    private static final String TASK_TEXT_COLOR   = '#0d47a1';

    // Site Visit - Scheduled
    private static final String SCHEDULE_BG_COLOR     = '#c5cae9';
    private static final String SCHEDULE_BORDER_COLOR = '#3f51b5';
    private static final String SCHEDULE_TEXT_COLOR   = '#1a237e';
    
    // Site Visit - Completed
    private static final String COMPLETED_BG_COLOR     = '#e8f5e9';
    private static final String COMPLETED_BORDER_COLOR = '#43a047';
    private static final String COMPLETED_TEXT_COLOR   = '#1b5e20';
    
    // Site Visit - Rescheduled
    private static final String RESCHEDULED_BG_COLOR     = '#fff9c4';
    private static final String RESCHEDULED_BORDER_COLOR = '#fbc02d';
    private static final String RESCHEDULED_TEXT_COLOR   = '#f57f17';
    
    // Site Visit - Cancelled
    private static final String CANCELLED_BG_COLOR     = '#ffcdd2';
    private static final String CANCELLED_BORDER_COLOR = '#d32f2f';
    private static final String CANCELLED_TEXT_COLOR   = '#b71c1c';
    
    @TestVisible
    private static Map<String, String> buildTaskMap(Task t) {
        Map<String, String> mapTask = new Map<String, String>();
        mapTask.put('id', t.Id);        
        mapTask.put('title', t.Subject);
        mapTask.put('type', 'task');

        if (t.StartDateTime__c != null && t.EndDateTime__c != null) {
            mapTask.put('start', String.valueOf(t.StartDateTime__c));
            mapTask.put('end', String.valueOf(t.EndDateTime__c));
            List<String> participants = new List<String>();
            if (t.TaskRelations != null) {
                for (TaskRelation tr : t.TaskRelations) {
                    if (tr.Relation != null) {
                        participants.add(tr.Relation.Name);
                    }
                }
            }
            mapTask.put('participants', JSON.serialize(participants));
        } else {
            mapTask.put('start', String.valueOf(t.ActivityDate));
            mapTask.put('assignedTo', t.Assigned_By__r != null ? t.Assigned_By__r.Name : '');
        }

        mapTask.put('assignedBy', t.Owner.Name);

        /* ===================================================================
           CHANGED: Replaced fixed blue color with dynamic color logic.
           
           Rule:
             - WhatId == null  →  No "Related To" record  →  BLUE
             - WhatId != null  →  Has "Related To" record  →  check status/date:
                   Status = Completed            →  GREEN
                   ActivityDate < today          →  RED  (overdue)
                   else                          →  YELLOW (pending)
        =================================================================== */
        Date today = Date.today();

        if (t.WhatId == null) {
            // ── No Related To record → Blue ──────────────────────────────
            mapTask.put('backgroundColor', '#e3f2fd');
            mapTask.put('borderColor',     '#2196f3');
            mapTask.put('textColor',       '#0d47a1');

        } else if (t.Status == 'Completed') {
            // ── Related + Completed → Green ──────────────────────────────
            mapTask.put('backgroundColor', '#e8f5e9');
            mapTask.put('borderColor',     '#43a047');
            mapTask.put('textColor',       '#1b5e20');

        } else if (t.ActivityDate != null && t.ActivityDate < today) {
            // ── Related + Overdue → Red ───────────────────────────────────
            mapTask.put('backgroundColor', '#ffcdd2');
            mapTask.put('borderColor',     '#d32f2f');
            mapTask.put('textColor',       '#b71c1c');

        } else {
            // ── Related + Pending → Yellow ────────────────────────────────
            mapTask.put('backgroundColor', '#fffde7');
            mapTask.put('borderColor',     '#ffd600');
            mapTask.put('textColor',       '#ff6f00');
        }
 
        return mapTask;
    }

    @TestVisible
    private static Map<String, String> buildProfileTaskMap(Task t) {
        Map<String, String> mapTask = new Map<String, String>();
        mapTask.put('id', t.Id);
        if(t.Assigned_By__c == UserInfo.getUserId()){
            mapTask.put('title', t.Subject + ' : ' + t.Owner.Name);
        } else {
            mapTask.put('title', t.Subject + ' : ' + t.Assigned_By__r.Name);
        }
        mapTask.put('start', String.valueOf(t.Due_Date_Time__c != null ? t.Due_Date_Time__c : t.ActivityDate));
        mapTask.put('status', t.Status);    
        mapTask.put('priority', t.Priority);
        mapTask.put('dueDate', String.valueOf(t.ActivityDate));
        mapTask.put('assignedBy', t.Assigned_By__c);        
        mapTask.put('assignedTo', t.OwnerId);
        mapTask.put('type', 'task');
        mapTask.put('reminder', String.valueOf(t.IsReminderSet));
        mapTask.put('reminderDateTime', String.valueOf(t.ReminderDateTime));
        mapTask.put('backgroundColor', TASK_BG_COLOR);
        mapTask.put('borderColor', TASK_BORDER_COLOR);
        mapTask.put('textColor', TASK_TEXT_COLOR);
        return mapTask;
    }

    @TestVisible
    private static Map<String, String> buildSiteVisitMap(Site_Visit__c sv) {
        Map<String, String> mapTask = new Map<String, String>();
        mapTask.put('id', sv.Id);
        mapTask.put('title', 'Site visit: ' + sv.Owner.Name);
        mapTask.put('start', String.valueOf(sv.Visit_Date_Time__c));        
        mapTask.put('status', sv.Status__c);
        mapTask.put('type', 'siteVisit');
      
        if(sv.Status__c == 'Scheduled'){
            mapTask.put('backgroundColor', SCHEDULE_BG_COLOR);
            mapTask.put('borderColor', SCHEDULE_BORDER_COLOR);
            mapTask.put('textColor', SCHEDULE_TEXT_COLOR);
        }
        if(sv.Status__c == 'Completed'){
            mapTask.put('backgroundColor', COMPLETED_BG_COLOR);
            mapTask.put('borderColor', COMPLETED_BORDER_COLOR);
            mapTask.put('textColor', COMPLETED_TEXT_COLOR);
        }
        if(sv.Status__c == 'Rescheduled'){
            mapTask.put('backgroundColor', RESCHEDULED_BG_COLOR);
            mapTask.put('borderColor', RESCHEDULED_BORDER_COLOR);
            mapTask.put('textColor', RESCHEDULED_TEXT_COLOR);
        }
        if(sv.Status__c == 'Cancelled'){
            mapTask.put('backgroundColor', CANCELLED_BG_COLOR);
            mapTask.put('borderColor', CANCELLED_BORDER_COLOR);
            mapTask.put('textColor', CANCELLED_TEXT_COLOR);
        }
        return mapTask;
    }
    
    @TestVisible
    private static Map<String, String> buildProfileSiteVisitMap(Site_Visit__c sv) {
        Map<String, String> mapTask = new Map<String, String>();
        mapTask.put('id', sv.Id);
        mapTask.put('title', 'Site visit: ' + sv.Opportunity__r.Name);
        mapTask.put('start', String.valueOf(sv.Visit_Date_Time__c));
        mapTask.put('status', sv.Status__c);
        mapTask.put('type', 'siteVisit');
        if(sv.Status__c == 'Scheduled'){
            mapTask.put('backgroundColor', SCHEDULE_BG_COLOR);
            mapTask.put('borderColor', SCHEDULE_BORDER_COLOR);
            mapTask.put('textColor', SCHEDULE_TEXT_COLOR);
        }
        if(sv.Status__c == 'Completed'){
            mapTask.put('backgroundColor', COMPLETED_BG_COLOR);
            mapTask.put('borderColor', COMPLETED_BORDER_COLOR);
            mapTask.put('textColor', COMPLETED_TEXT_COLOR);
        }
        if(sv.Status__c == 'Rescheduled'){
            mapTask.put('backgroundColor', RESCHEDULED_BG_COLOR);
            mapTask.put('borderColor', RESCHEDULED_BORDER_COLOR);
            mapTask.put('textColor', RESCHEDULED_TEXT_COLOR);
        }
        if(sv.Status__c == 'Cancelled'){
            mapTask.put('backgroundColor', CANCELLED_BG_COLOR);
            mapTask.put('borderColor', CANCELLED_BORDER_COLOR);
            mapTask.put('textColor', CANCELLED_TEXT_COLOR);
        }
        return mapTask;
    }

    @AuraEnabled
    public static void createTask(String taskValues, String selectedUsersJson) {
        System.debug('Raw taskValues: ' + taskValues);
        List<Object> selectedUsersList = (List<Object>) JSON.deserializeUntyped(selectedUsersJson);
        Map<Id, String> userIdToNameMap = new Map<Id, String>();
        for (Object userObj : selectedUsersList) {
            Map<String, Object> userMap = (Map<String, Object>) userObj;
            userIdToNameMap.put((Id) userMap.get('Id'), (String) userMap.get('Name'));
        }
        TaskWrapper taskInput;
        try {
            taskInput = (TaskWrapper) JSON.deserialize(taskValues, TaskWrapper.class);
        } catch (Exception ex) {
            throw new AuraHandledException('Error deserializing taskValues: ' + ex.getMessage());
        }
        if (taskInput == null) {
            throw new AuraHandledException('taskInput is null after deserialization.');
        }

        List<User> userList = [SELECT Id, FirstName, LastName, Username, UserType, IsActive, Email FROM User WHERE Id IN :userIdToNameMap.keySet()];
        Set<String> usernames = new Set<String>();
        if (!userList.isEmpty()) {
            for (User u : userList) {
                usernames.add(u.Username);
            }
        }
        List<Account> accList = [SELECT Id FROM Account WHERE Name = 'Account_For_Calendar_Task' LIMIT 1];
        Account accountRecord;
        if (!accList.isEmpty()) {
            accountRecord = accList[0];
        } else {
            accountRecord = new Account(Name = 'Account_For_Calendar_Task');
            insert accountRecord;
        }

        Map<String, Contact> existingContacts = new Map<String, Contact>();
        for (Contact c : [SELECT Id, User_name__c FROM Contact WHERE User_name__c IN :usernames]) {
            existingContacts.put(c.User_name__c, c);
        }
        Map<String, Id> usernameToContactId = new Map<String, Id>();
        List<Contact> contactsToInsert = new List<Contact>();
        for (User u : userList) {
            if (!existingContacts.containsKey(u.Username)) {
                Contact newCon = new Contact(
                    LastName     = String.isNotBlank(u.LastName) ? u.LastName : 'Unknown',
                    FirstName    = u.FirstName,
                    Email        = u.Email,
                    User_name__c = u.Username,
                    AccountId    = accountRecord.Id,
                    User__c      = u.Id
                );
                contactsToInsert.add(newCon);
            } else {
                usernameToContactId.put(u.Username, existingContacts.get(u.Username).Id);
            }
        }
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
            for (Contact c : contactsToInsert) {
                usernameToContactId.put(c.User_name__c, c.Id);
            }
        }

        Group g = [SELECT Id, DeveloperName, Type FROM Group WHERE DeveloperName = 'ContactShare' AND Type = 'Regular' LIMIT 1];
        List<ContactShare> contactShares = new List<ContactShare>();
        for (User u : userList) {
            if (usernameToContactId.containsKey(u.Username)) {
                ContactShare cs = new ContactShare();
                cs.ContactId          = usernameToContactId.get(u.Username);
                cs.UserOrGroupId      = g.Id;
                cs.ContactAccessLevel = 'Edit';
                contactShares.add(cs);
            }
        }
        if (!contactShares.isEmpty()) {
            try {
                insert contactShares;
            } catch (Exception e) {
                System.debug('Contact sharing skipped or failed: ' + e.getMessage());
            }
        }

        List<String> startParts = taskInput.StartTime.split(':');
        Time startTime = Time.newInstance(Integer.valueOf(startParts[0]), Integer.valueOf(startParts[1]), 0, 0);
        List<String> endParts = taskInput.EndTime.split(':');
        Time endTime = Time.newInstance(Integer.valueOf(endParts[0]), Integer.valueOf(endParts[1]), 0, 0);
        Date startDate     = Date.valueOf(taskInput.StartDate);
        Date endDate       = Date.valueOf(taskInput.EndDate);
        DateTime startDateTime = DateTime.newInstance(startDate, startTime);
        DateTime endDateTime   = DateTime.newInstance(endDate, endTime);

        List<Id> contactIds = new List<Id>(usernameToContactId.values());
        List<Task> createdTask = new List<Task>();
        for (Id conId : contactIds) {
            Task taskRec = new Task(
                Subject               = String.valueOf(taskInput.Subject),
                StartDateTime__c      = startDateTime,
                EndDateTime__c        = endDateTime,
                IsRecurring__c        = taskInput.IsRecurring,
                Recurrence_Type__c    = taskInput.RecurrenceType,
                Repeat_On__c          = taskInput.RepeatOn,
                WhoId                 = conId,
                Description           = taskInput.Description,
                ActivityDate          = startDate,
                Task_Assigned_Date__c = startDate
            );
            createdTask.add(taskRec);
        }
        List<Task> tasksToInsert = new List<Task>();

        try {
            if (taskInput.isRecurring && !String.isBlank(taskInput.recurrenceType)) {
                Date startDt2 = Date.valueOf(taskInput.startDate);
                Date endDt2   = Date.valueOf(taskInput.endDate);

                if (taskInput.recurrenceType == 'Daily') {
                    for (Date d = startDt2; d <= endDt2; d = d.addDays(1)) {
                        DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
                        if (dt.format('EEEE') == 'Sunday') continue;
                        DateTime dailyStart = DateTime.newInstance(d, startTime);
                        DateTime dailyEnd   = DateTime.newInstance(d, endTime);
                        for (Task tk : createdTask) {
                            Task clonedTask = tk.clone(false, false, false, false);
                            clonedTask.StartDateTime__c      = dailyStart;
                            clonedTask.EndDateTime__c        = dailyEnd;
                            clonedTask.ActivityDate          = d;
                            clonedTask.Task_Assigned_Date__c = d;
                            tasksToInsert.add(clonedTask);
                        }
                    }
                }
                if (taskInput.RecurrenceType == 'Weekly' && !String.isBlank(taskInput.RepeatOn)) {
                    Set<String> repeatDays = new Set<String>();
                    for (String day : taskInput.RepeatOn.replace(';', ',').split(',')) {
                        String shortDay = day.trim().substring(0,3).toLowerCase();
                        if (shortDay != 'sun') repeatDays.add(shortDay);
                    }
                    for (Date d = startDt2; d <= endDt2; d = d.addDays(1)) {
                        DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
                        String dayNameShort = dt.format('EEE').toLowerCase();
                        if (repeatDays.contains(dayNameShort)) {
                            DateTime dailyStart = DateTime.newInstance(d, startTime);
                            DateTime dailyEnd   = DateTime.newInstance(d, endTime);
                            for (Task tk : createdTask) {
                                Task clonedTask = tk.clone(false, false, false, false);
                                clonedTask.StartDateTime__c      = dailyStart;
                                clonedTask.EndDateTime__c        = dailyEnd;
                                clonedTask.ActivityDate          = d;
                                clonedTask.Task_Assigned_Date__c = d;
                                tasksToInsert.add(clonedTask);
                            }
                        }
                    }
                }
                if (taskInput.RecurrenceType == 'Monthly') {
                    Integer dayOfMonth = startDt2.day();
                    Date d = startDt2;
                    while (d <= endDt2) {
                        if (dayOfMonth <= Date.daysInMonth(d.year(), d.month())) {
                            Date taskDate = Date.newInstance(d.year(), d.month(), dayOfMonth);
                            DateTime dt = DateTime.newInstance(taskDate, Time.newInstance(0,0,0,0));
                            if (dt.format('EEE').toLowerCase() == 'sun') {
                                taskDate = taskDate.addDays(1);
                            }
                            DateTime dailyStart = DateTime.newInstance(taskDate, startTime);
                            DateTime dailyEnd   = DateTime.newInstance(taskDate, endTime);
                            for (Task tk : createdTask) {
                                Task clonedTask = tk.clone(false, false, false, false);
                                clonedTask.StartDateTime__c      = dailyStart;
                                clonedTask.EndDateTime__c        = dailyEnd;
                                clonedTask.ActivityDate          = taskDate;
                                clonedTask.Task_Assigned_Date__c = taskDate;
                                tasksToInsert.add(clonedTask);
                            }
                        }
                        d = d.addMonths(1);
                    }
                }
                insert tasksToInsert;
            } else {
                insert createdTask;
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error creating Task: ' + ex.getMessage());
        }
    }

    public class TaskWrapper {
        @AuraEnabled public String  Subject;
        @AuraEnabled public Date    StartDate;
        @AuraEnabled public Date    EndDate;
        @AuraEnabled public String  StartTime;
        @AuraEnabled public String  EndTime;
        @AuraEnabled public Boolean IsRecurring;
        @AuraEnabled public String  RecurrenceType;
        @AuraEnabled public String  RepeatOn;
        @AuraEnabled public String  Description;
    }

    @AuraEnabled
    public static String createContactsAndEvent(String eventValues, String selectedUsersJson) {
        System.debug('Raw eventValues: ' + eventValues);
        List<Object> selectedUsersList = (List<Object>) JSON.deserializeUntyped(selectedUsersJson);
        Map<Id, String> userIdToNameMap = new Map<Id, String>();
        for (Object userObj : selectedUsersList) {
            Map<String, Object> userMap = (Map<String, Object>) userObj;
            userIdToNameMap.put((Id) userMap.get('Id'), (String) userMap.get('Name'));
        }
        EventWrapper eventInput;
        try {
            eventInput = (EventWrapper) JSON.deserialize(eventValues, EventWrapper.class);
        } catch (Exception ex) {
            throw new AuraHandledException('Error deserializing eventValues: ' + ex.getMessage());
        }
        if (eventInput == null) {
            throw new AuraHandledException('eventInput is null after deserialization.');
        }

        List<User> userList = [SELECT Id, FirstName, LastName, Username, Email FROM User WHERE Id IN :userIdToNameMap.keySet()];
        Set<String> usernames = new Set<String>();
        for (User u : userList) { usernames.add(u.Username); }

        List<Account> accList = [SELECT Id FROM Account WHERE Name = 'Account_For_Calendar_Task' LIMIT 1];
        Account accountRecord;
        if (!accList.isEmpty()) {
            accountRecord = accList[0];
        } else {
            accountRecord = new Account(Name = 'Account_For_Calendar_Task');
            insert accountRecord;
        }

        Map<String, Contact> existingContacts = new Map<String, Contact>();
        for (Contact c : [SELECT Id, User_name__c FROM Contact WHERE User_name__c IN :usernames]) {
            existingContacts.put(c.User_name__c, c);
        }
        Map<String, Id> usernameToContactId = new Map<String, Id>();
        List<Contact> contactsToInsert = new List<Contact>();
        for (User u : userList) {
            if (!existingContacts.containsKey(u.Username)) {
                Contact newCon = new Contact(
                    LastName     = String.isNotBlank(u.LastName) ? u.LastName : 'Unknown',
                    FirstName    = u.FirstName,
                    Email        = u.Email,
                    User_name__c = u.Username,
                    AccountId    = accountRecord.Id,
                    User__c      = u.Id
                );
                contactsToInsert.add(newCon);
            } else {
                usernameToContactId.put(u.Username, existingContacts.get(u.Username).Id);
            }
        }
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
            for (Contact c : contactsToInsert) {
                usernameToContactId.put(c.User_name__c, c.Id);
            }
        }

        List<ContactShare> contactShares = new List<ContactShare>();
        for (User u : userList) {
            if (usernameToContactId.containsKey(u.Username)) {
                ContactShare cs = new ContactShare();
                cs.ContactId          = usernameToContactId.get(u.Username);
                cs.UserOrGroupId      = u.Id;
                cs.ContactAccessLevel = 'Edit';
                contactShares.add(cs);
            }
        }
        if (!contactShares.isEmpty()) {
            try { insert contactShares; } catch (Exception e) {
                System.debug('Contact sharing skipped or failed: ' + e.getMessage());
            }
        }

        List<String> startParts = eventInput.StartTime.split(':');
        Time startTime = Time.newInstance(Integer.valueOf(startParts[0]), Integer.valueOf(startParts[1]), 0, 0);
        List<String> endParts = eventInput.EndTime.split(':');
        Time endTime = Time.newInstance(Integer.valueOf(endParts[0]), Integer.valueOf(endParts[1]), 0, 0);
        Date startDate     = Date.valueOf(eventInput.StartDate);
        Date endDate       = Date.valueOf(eventInput.EndDate);
        DateTime startDateTime = DateTime.newInstance(startDate, startTime);
        DateTime endDateTime   = DateTime.newInstance(endDate, endTime);

        List<Id> contactIds = new List<Id>(usernameToContactId.values());
        Event eventRec = new Event(
            Subject            = String.valueOf(eventInput.Subject),
            StartDateTime      = startDateTime,
            EndDateTime        = endDateTime,
            IsRecurring__c     = eventInput.IsRecurring,
            Recurrence_Type__c = eventInput.RecurrenceType,
            Repeat_On__c       = eventInput.RepeatOn,
            WhoId              = contactIds[0],
            Location           = eventInput.Location,
            Description        = eventInput.Description
        );
        List<Event> eventsToInsert = new List<Event>();

        try {
            if (eventInput.isRecurring && !String.isBlank(eventInput.recurrenceType)) {
                Date startDt2 = Date.valueOf(eventInput.startDate);
                Date endDt2   = Date.valueOf(eventInput.endDate);

                if (eventInput.recurrenceType == 'Daily') {
                    for (Date d = startDt2; d <= endDt2; d = d.addDays(1)) {
                        DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
                        if (dt.format('EEEE') == 'Sunday') continue;
                        Event clonedEvent = eventRec.clone(false, false, false, false);
                        clonedEvent.StartDateTime = DateTime.newInstance(d, startTime);
                        clonedEvent.EndDateTime   = DateTime.newInstance(d, endTime);
                        eventsToInsert.add(clonedEvent);
                    }
                }
                if (eventInput.RecurrenceType == 'Weekly' && !String.isBlank(eventInput.RepeatOn)) {
                    Set<String> repeatDays = new Set<String>();
                    for (String day : eventInput.RepeatOn.replace(';', ',').split(',')) {
                        String shortDay = day.trim().substring(0,3).toLowerCase();
                        if (shortDay != 'sun') repeatDays.add(shortDay);
                    }
                    for (Date d = startDt2; d <= endDt2; d = d.addDays(1)) {
                        DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
                        if (repeatDays.contains(dt.format('EEE').toLowerCase())) {
                            Event clonedEvent = eventRec.clone(false, false, false, false);
                            clonedEvent.StartDateTime = DateTime.newInstance(d, startTime);
                            clonedEvent.EndDateTime   = DateTime.newInstance(d, endTime);
                            eventsToInsert.add(clonedEvent);
                        }
                    }
                }
                if (eventInput.RecurrenceType == 'Monthly') {
                    Integer dayOfMonth = startDt2.day();
                    Date d = startDt2;
                    while (d <= endDt2) {
                        if (dayOfMonth <= Date.daysInMonth(d.year(), d.month())) {
                            Date eventDate = Date.newInstance(d.year(), d.month(), dayOfMonth);
                            DateTime dt = DateTime.newInstance(eventDate, Time.newInstance(0,0,0,0));
                            if (dt.format('EEE').toLowerCase() == 'sun') {
                                eventDate = eventDate.addDays(1);
                            }
                            Event clonedEvent = eventRec.clone(false, false, false, false);
                            clonedEvent.StartDateTime = DateTime.newInstance(eventDate, startTime);
                            clonedEvent.EndDateTime   = DateTime.newInstance(eventDate, endTime);
                            eventsToInsert.add(clonedEvent);
                        }
                        d = d.addMonths(1);
                    }
                }
                insert eventsToInsert;
                if (contactIds.size() > 1) {
                    List<EventRelation> relations = new List<EventRelation>();
                    for (Event e : eventsToInsert) {
                        for (Integer i = 1; i < contactIds.size(); i++) {
                            relations.add(new EventRelation(EventId = e.Id, RelationId = contactIds[i], IsParent = true));
                        }
                    }
                    if (!relations.isEmpty()) insert relations;
                }
                return eventsToInsert.isEmpty() ? null : eventsToInsert[0].Id;

            } else {
                insert eventRec;
                if (contactIds.size() > 1) {
                    List<EventRelation> relations = new List<EventRelation>();
                    for (Integer i = 1; i < contactIds.size(); i++) {
                        relations.add(new EventRelation(EventId = eventRec.Id, RelationId = contactIds[i], IsParent = true));
                    }
                    if (!relations.isEmpty()) insert relations;
                }
                return eventRec.Id;
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error creating Event: ' + ex.getMessage());
        }
    }

    public class EventWrapper {
        @AuraEnabled public String  Subject;
        @AuraEnabled public Date    StartDate;
        @AuraEnabled public Date    EndDate;
        @AuraEnabled public String  StartTime;
        @AuraEnabled public String  EndTime;
        @AuraEnabled public Boolean IsRecurring;
        @AuraEnabled public String  RecurrenceType;
        @AuraEnabled public String  RepeatOn;
        @AuraEnabled public String  Location;
        @AuraEnabled public String  Description;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getUserName() {
        Id currentUserId = UserInfo.getUserId();
        try {
            User u = [SELECT Id, Profile.Name, UserName FROM User WHERE Id = :currentUserId LIMIT 1];
            if (u.Profile.Name == 'System Administrator') return true;
            if (u.UserName.contains('chennai@allwarehouses.in')) return true;
            return false;
        } catch (Exception e) {
            throw new AuraHandledException('Error checking user access: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateTaskOrEvent(String recordId, String newStartDate, String newEndDate, String recordType) {
        System.debug('newStartDate' + newStartDate);
        try {
            String cleanStart = newStartDate.replaceAll('[APT]', ' ');
            String cleanEnd   = newEndDate.replaceAll('[APT]', ' ');
            DateTime startDateTime = DateTime.valueOf(cleanStart);
            DateTime endDateTime   = DateTime.valueOf(cleanEnd);
            Date startDate = startDateTime.date();

            if (recordType == 'task') {
                Task taskToUpdate = [SELECT Id FROM Task WHERE Id = :recordId LIMIT 1];
                taskToUpdate.ActivityDate    = startDate;
                taskToUpdate.StartDateTime__c = startDateTime;
                taskToUpdate.EndDateTime__c   = endDateTime;
                update taskToUpdate;
            } else if (recordType == 'event') {
                Event eventToUpdate = [SELECT Id FROM Event WHERE Id = :recordId LIMIT 1];
                eventToUpdate.StartDateTime = startDateTime;
                eventToUpdate.EndDateTime   = endDateTime;
                update eventToUpdate;
            } else if (recordType == 'followUp') {
                Task followUpTaskToUpdate = [SELECT Id, ReminderDateTime FROM Task WHERE Id = :recordId LIMIT 1];
                followUpTaskToUpdate.ReminderDateTime = startDateTime;
                followUpTaskToUpdate.ActivityDate     = startDate;
                update followUpTaskToUpdate;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating record: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isSystemAdmin() {
        Id profileId = UserInfo.getProfileId();
        String profileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
        return profileName == 'System Administrator';
    }
}