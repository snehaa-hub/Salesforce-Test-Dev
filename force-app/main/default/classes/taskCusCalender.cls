public with sharing class taskCusCalender {
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getTasksForCalendar() {
        List<Map<String, String>> taskList = new List<Map<String, String>>();
        Id currentUserId = UserInfo.getUserId();
        String profileName = [
            SELECT Profile.Name FROM User WHERE Id = :currentUserId
        ].Profile.Name;
        
        
        if (profileName == 'System Administrator') {
            for (Task__c t : [SELECT Id, Subject__c, OwnerId,Assigned_From__c,Assigned_To__c
                       FROM Task__c]) {
                           
                           taskList.add(buildTaskMap(t));
                       }
            
            for (Site_Visit__c sv : [
                SELECT Id, Name, Visit_Date__c,Visit_Date_Time__c, OwnerId, Owner.Name, Opportunity__r.Name
                FROM Site_Visit__c 
                WHERE Visit_Date__c != NULL
            ]) {
                taskList.add(buildSiteVisitMap(sv));
            }
            
        } else {
            
            for (Task__c t : [SELECT Id, Subject__c, OwnerId,Assigned_From__c,Assigned_To__c
                        FROM Task__c
    
        ]) {
            taskList.add(buildProfileTaskMap(t));
        }

         
            
            for (Site_Visit__c sv : [
                SELECT Id, Name, Visit_Date__c,Visit_Date_Time__c, OwnerId, Owner.Name, Opportunity__r.Name
                FROM Site_Visit__c 
                WHERE Visit_Date__c != NULL AND OwnerId = :currentUserId
            ]) {
                taskList.add(buildProfileSiteVisitMap(sv));
            }
        }
        
        return taskList;
    }
    
    
    //Task bgcolor
    private static final String TASK_BG_COLOR = '#e3f2fd';
    private static final String TASK_BORDER_COLOR = '#2196f3';
    private static final String TASK_TEXT_COLOR = '#0d47a1';
    
    //siteVisit schedule 
    private static final String SCHEDULE_BG_COLOR = '#c5cae9';
    private static final String SCHEDULE_BORDER_COLOR = '#3f51b5';
    private static final String SCHEDULE_TEXT_COLOR = '#1a237e';
    
    
    //sitevisit Completed
    
    private static final String COMPLETED_BG_COLOR = '#e8f5e9';
    private static final String COMPLETED_BORDER_COLOR = '#43a047';
    private static final String COMPLETED_TEXT_COLOR = '#1b5e20';
    
    
    
    //siteVisit Rescheduled
    private static final String RESCHEDULED_BG_COLOR = '#fff9c4';
    private static final String RESCHEDULED_BORDER_COLOR = '#fbc02d';
    private static final String RESCHEDULED_TEXT_COLOR = '#f57f17';
    
    //siteVisit Cancelled
    private static final String CANCELLED_BG_COLOR = '#ffcdd2';
    private static final String CANCELLED_BORDER_COLOR = '#d32f2f';
    private static final String CANCELLED_TEXT_COLOR = '#b71c1c';
    
    
    private static Map<String, String> buildTaskMap(Task__c t) {
        Map<String, String> mapTask = new Map<String, String>();
        mapTask.put('id', t.Id);        
        mapTask.put('title', t.Subject__c);
       
        
        mapTask.put('assignedFrom', t.Assigned_From__c);        
        mapTask.put('assignedTo', t.Assigned_To__c);
        mapTask.put('type', 'task');
       
        
        mapTask.put('backgroundColor', TASK_BG_COLOR);
        mapTask.put('borderColor', TASK_BORDER_COLOR);
        mapTask.put('textColor', TASK_TEXT_COLOR);
        return mapTask;
    }
    

    @TestVisible
private static Map<String, String> buildProfileTaskMap(Task__c t) {
        Map<String, String> mapTask = new Map<String, String>();
        mapTask.put('id', t.Id);        
        mapTask.put('title', t.Subject__c);
        
        
       
        
        mapTask.put('assignedFrom', t.Assigned_From__c);        
        mapTask.put('assignedTo', t.Assigned_To__c);
        mapTask.put('type', 'task');
       
        
        mapTask.put('backgroundColor', TASK_BG_COLOR);
        mapTask.put('borderColor', TASK_BORDER_COLOR);
        mapTask.put('textColor', TASK_TEXT_COLOR);
        return mapTask;
    }
    
    private static Map<String, String> buildSiteVisitMap(Site_Visit__c sv) {
        Map<String, String> mapTask = new Map<String, String>();
        mapTask.put('id', sv.Id);
        mapTask.put('title', 'Site visit: ' + sv.Owner.Name);
        mapTask.put('start', String.valueOf(sv.Visit_Date_Time__c));        
        // mapTask.put('status', sv.Status__c);
        mapTask.put('type', 'siteVisit');
      
        // if(sv.Status__c == 'Scheduled'){
        //     mapTask.put('backgroundColor', SCHEDULE_BG_COLOR);
        //     mapTask.put('borderColor', SCHEDULE_BORDER_COLOR);
        //     mapTask.put('textColor',SCHEDULE_TEXT_COLOR);
        // }
        // if(sv.Status__c == 'Completed'){
        //     mapTask.put('backgroundColor', COMPLETED_BG_COLOR);
        //     mapTask.put('borderColor',COMPLETED_BORDER_COLOR);
        //     mapTask.put('textColor',COMPLETED_TEXT_COLOR);
        // }
        // if(sv.Status__c == 'Rescheduled'){
        //     mapTask.put('backgroundColor', RESCHEDULED_BG_COLOR);
        //     mapTask.put('borderColor',RESCHEDULED_BORDER_COLOR);
        //     mapTask.put('textColor',RESCHEDULED_TEXT_COLOR);
        // }
        // if(sv.Status__c == 'Cancelled'){
        //     mapTask.put('backgroundColor', CANCELLED_BG_COLOR);
        //     mapTask.put('borderColor',CANCELLED_BORDER_COLOR);
        //     mapTask.put('textColor',CANCELLED_TEXT_COLOR);
        // }
        
        return mapTask;
    }
    
    
    private static Map<String, String> buildProfileSiteVisitMap(Site_Visit__c sv) {
        Map<String, String> mapTask = new Map<String, String>();
        mapTask.put('id', sv.Id);
        mapTask.put('title', 'Site visit: ' + sv.Opportunity__r.Name);
         mapTask.put('start', String.valueOf(sv.Visit_Date_Time__c));
        // mapTask.put('status', sv.Status__c);
        mapTask.put('type', 'siteVisit');
        mapTask.put('backgroundColor', '#e8f5e9');
        mapTask.put('borderColor', '#43a047');
        mapTask.put('textColor', '#1b5e20');
        // if(sv.Status__c == 'Scheduled'){
        //     mapTask.put('backgroundColor', SCHEDULE_BG_COLOR);
        //     mapTask.put('borderColor', SCHEDULE_BORDER_COLOR);
        //     mapTask.put('textColor',SCHEDULE_TEXT_COLOR);
        // }
        // if(sv.Status__c == 'Completed'){
        //    mapTask.put('backgroundColor', COMPLETED_BG_COLOR);
        //     mapTask.put('borderColor',COMPLETED_BORDER_COLOR);
        //     mapTask.put('textColor',COMPLETED_TEXT_COLOR);
        // }
        // if(sv.Status__c == 'Rescheduled'){
        //     mapTask.put('backgroundColor', RESCHEDULED_BG_COLOR);
        //     mapTask.put('borderColor',RESCHEDULED_BORDER_COLOR);
        //     mapTask.put('textColor',RESCHEDULED_TEXT_COLOR);
        // }
        // if(sv.Status__c == 'Cancelled'){
        //     mapTask.put('backgroundColor', CANCELLED_BG_COLOR);
        //     mapTask.put('borderColor',CANCELLED_BORDER_COLOR);
        //     mapTask.put('textColor',CANCELLED_TEXT_COLOR);
        // }
        
        return mapTask;
    }
    
    
    
    
    // Get Picklist Values for Subject Field
    @AuraEnabled(cacheable=true)
    public static List<String> getSubjectPicklistValues() {
        List<String> subjectPicklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Task__c.Subject__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            subjectPicklistValues.add(entry.getValue());
        }
        return subjectPicklistValues;
    }
    
    // Get Picklist Values for Status Field
    // @AuraEnabled(cacheable=true)
    // public static List<String> getStatusPicklistValues() {
    //     List<String> statusPicklistValues = new List<String>();
    //     // Schema.DescribeFieldResult fieldResult = Task__c.Status__c.getDescribe();
    //     List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
    //     for (Schema.PicklistEntry entry : picklistEntries) {
    //         statusPicklistValues.add(entry.getValue());
    //     }
    //     return statusPicklistValues;
    // }
    
    // // Get Picklist Values for priority Field
    // @AuraEnabled(cacheable=true)
    // public static List<String> getPriorityPicklistValues() {
    //     List<String> priorityPicklistValues = new List<String>();
    //     Schema.DescribeFieldResult fieldResult = Task__c.Priority__c.getDescribe();
    //     List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
    //     for (Schema.PicklistEntry entry : picklistEntries) {
    //         priorityPicklistValues.add(entry.getValue());
    //     }
    //     return priorityPicklistValues;
    // }
    
    

@AuraEnabled
public static String createTask(String taskValues) {
    System.debug('Raw taskValues: ' + taskValues);

    TaskWrapper taskInput;

  
    try {
        taskInput = (TaskWrapper) JSON.deserialize(taskValues, TaskWrapper.class);
    } catch (Exception ex) {
        throw new AuraHandledException('Error deserializing taskValues: ' + ex.getMessage());
    }

    if (taskInput == null) {
        throw new AuraHandledException('taskInput is null after deserialization.');
    }

    if (String.isBlank(taskInput.assignedByUserId)) {
        throw new AuraHandledException('assignedByUserId is missing in input.');
    }

    
    
    
    Task__c newTask = new Task__c();
    newTask.Subject__c = taskInput.Subject;
    newTask.Assigned_From__c = taskInput.OwnerId;
    newTask.Assigned_To__c = taskInput.assignedByUserId;
    //newTask.WhoId = contactRecord.Id;
    // newTask.Status__c = taskInput.Status;
    // newTask.Priority__c = taskInput.Priority;

    
    if (String.isNotBlank(taskInput.dueDateTime)) {
        try {
            String dueDateTimeStr = taskInput.dueDateTime.replace('T', ' ');
            if (dueDateTimeStr.length() == 16) dueDateTimeStr += ':00';
        } catch (Exception ex) {
            throw new AuraHandledException('Invalid dueDateTime format: ' + taskInput.dueDateTime);
        }
    }

   
   

    
    try {
        insert newTask;
        System.debug('Task created successfully: ' + newTask.Id);
        return newTask.Id;
    } catch (Exception ex) {
        throw new AuraHandledException('Error creating Task: ' + ex.getMessage());
    }
}


    public class TaskWrapper {
        @AuraEnabled public String Subject;
        @AuraEnabled public String OwnerId;
        @AuraEnabled public String assignedByUserId;
        @AuraEnabled public String Status;
        @AuraEnabled public String Priority;
        
        @AuraEnabled public String ActivityDate;
       
        @AuraEnabled public String dueDateTime;
    }  
    
}