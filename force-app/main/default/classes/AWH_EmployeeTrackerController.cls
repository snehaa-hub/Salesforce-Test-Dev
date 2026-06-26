/**
* @File Name : AWH_EmployeeTrackerController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 19, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 19, 2025 |   | Initial Version
**/
public with sharing class AWH_EmployeeTrackerController {
   @AuraEnabled
    public static List<User> userdetails(Id userId){
        
        List<User> Userinfo =[Select Id, Name,Email From User Where Id =: userId];
        
        //, MediumPhotoUrl 
        
        Return Userinfo;
    }

     @AuraEnabled
    public static List<Employee_Time_Sheet__c> getempcheckInRecords(string empconId, date todaysdate){
        
      //  String todays = String.valueOf(date.today());
        //Date todays = date.newinstance(todaysdate.year(), todaysdate.month(), todaysdate.day()).format('yyyy-MM-dd');
        
        //Datetime.newInstance(d.year(), d.month(), d.day()).format('yyy-MM-dd') 
        
        
        
       // System.debug('date :'+String.valueOf(todays));
        List<Employee_Time_Sheet__c> empfam = [Select Id, Name, CreatedDate, Time_In__c, Time_Out__c, Date__c,Comments__c,
                                            Employee__c,Entry_Type__c,Purpose_of_Visit__c,Name_of_the_Client__c,No_of_prop_added_in_salesforce__c,
											No_of_property_inspected__c,No_of_property_mapped__c,No_of_property_sent_in_group__c,Location__c
											  From Employee_Time_Sheet__c 
                                            Where Employee__c =:empconId 
                                            AND CreatedDate >: todaysdate Order by CreatedDate ASC ];
        
        return empfam;
         
    }

	 @AuraEnabled
    public static List<Employee_Time_Sheet_Line_Item__c> getempLineItem(string empId){
        
      //  String todays = String.valueOf(date.today());
        //Date todays = date.newinstance(todaysdate.year(), todaysdate.month(), todaysdate.day()).format('yyyy-MM-dd');
        
        //Datetime.newInstance(d.year(), d.month(), d.day()).format('yyy-MM-dd') 
        
        
        
       // System.debug('date :'+String.valueOf(todays));
        List<Employee_Time_Sheet_Line_Item__c> empfam = [Select Id, Name, CreatedDate, Time_In__c, Time_Out__c, Comments__c,Is_Own_Vehicle__c,
                                           Entry_Type__c,Purpose_of_Visit__c,Name_of_the_Client__c,Location__c,Check_In_Km__c,Check_Out_Km__c,Employee_Time_Sheet__c
											  From Employee_Time_Sheet_Line_Item__c 
                                            Where Employee_Time_Sheet__c =:empId Order by CreatedDate ASC ];
        
        return empfam;
         
    }

     @AuraEnabled
    public static String saveLeave(Employee_Leave_Sheet__c leaveRec) {
        try {
            leaveRec.Employee__c = UserInfo.getUserId(); // logged-in user
            leaveRec.Leave_Status__c = 'Submitted'; // Default status
            leaveRec.Applied_Date__c = System.today(); // Set Applied_Date__c to today's date
            
            insert leaveRec;
            Id adminId = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1].Id;
            AWH_EmployeeTrackerController.sendNotification(adminId, 
            'A new leave request has been submitted by ' + UserInfo.getName(), 
            leaveRec.Id);
            return 'SUCCESS';
        } catch (Exception e) {
            return 'ERROR: ' + e.getMessage();
        }
    }
    @AuraEnabled
    public static String updateLeave(Employee_Leave_Sheet__c leaveRec) {
        try {
            if(leaveRec.Leave_Status__c == 'Cancelled'){
                leaveRec.Reason__c = 'Cancelled'; // Set Reason to 'Cancelled'
            }
            else if(leaveRec.Leave_Status__c == 'Approved' || leaveRec.Leave_Status__c == 'Rejected'){
                leaveRec.Approval_Date__c = System.today(); // Set Approval_Date__c to current date and time
                leaveRec.Approver__c = UserInfo.getUserId(); // Set Approver to logged-in user
            }
            Employee_Leave_Sheet__c existingLeave = [SELECT Id, Employee__c, Leave_Status__c,Comment__c FROM Employee_Leave_Sheet__c WHERE Id = :leaveRec.Id LIMIT 1];
            String statusMessage = '';
                if(leaveRec.Comment__c != null && existingLeave.Comment__c != leaveRec.Comment__c){
                   statusMessage = 'Your leave request comment has been Updated : ' + leaveRec.Comment__c;
                }
                
            
            update leaveRec;
            Employee_Leave_Sheet__c existingLeave1 = [SELECT Id, Employee__c, Leave_Status__c,Comment__c FROM Employee_Leave_Sheet__c WHERE Id = :leaveRec.Id LIMIT 1];

            
            if (existingLeave1.Employee__c != null) {
                if(existingLeave.Leave_Status__c != existingLeave1.Leave_Status__c){ 
                   statusMessage = 'Your leave request has been ' + existingLeave1.Leave_Status__c;
                }
                // Send notification to the employee
            AWH_EmployeeTrackerController.sendNotification(existingLeave1.Employee__c, 
                statusMessage, 
                existingLeave1.Id);
            }
            
            return 'SUCCESS';
        } catch (Exception e) {
            return 'ERROR: ' + e.getMessage();
        }
    }

    public static void sendNotification(Id targetUserId, String message, String relatedRecordId) {
        try {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Leave Update');
            notification.setBody(message);
            notification.setNotificationTypeId(getNotificationTypeId('Leave_Notification')); // API name from setup
            notification.setTargetId(relatedRecordId); // Related record
            notification.setSenderId(UserInfo.getUserId());

            notification.send(new Set<String>{targetUserId});
        } catch (Exception e) {
            System.debug('Notification Error: ' + e.getMessage());
        }
    }

    // Get Notification Type Id by DeveloperName
    private static Id getNotificationTypeId(String developerName) {
        return [SELECT Id FROM CustomNotificationType WHERE DeveloperName = :developerName LIMIT 1].Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<Employee_Leave_Sheet__c> getMyLeaves() {
        return [
            SELECT Id, Name, Start_Date__c, End_Date__c, Leave_Type__c, Reason__c, Leave_Status__c, Applied_Date__c,Half_Day_Period__c, Approver__c, Approval_Date__c,Employee__r.Name ,Employee__r.Username, Comment__c, Approver__r.Name
            FROM Employee_Leave_Sheet__c
            WHERE Employee__c = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC
        ];
    }

     @AuraEnabled(cacheable=true)
    public static List<Employee_Leave_Sheet__c> getAllLeaves() {
        // Id currentUserId = UserInfo.getUserId();
        // return [
        //     SELECT Id, Name, Start_Date__c, End_Date__c, Leave_Type__c, Reason__c, Leave_Status__c, Applied_Date__c,Half_Day_Period__c, Approver__c,Approver__r.Name, Approval_Date__c,Employee__r.Name ,Employee__r.Username,Comment__c
        //     FROM Employee_Leave_Sheet__c
        //     WHERE Employee__c != null
        //    // AND Employee__c != :currentUserId 
        //     AND Leave_Status__c != 'Cancelled'
        //     AND Leave_Status__c != 'Draft'
        //     ORDER BY CreatedDate DESC
        // ];

                List<Employee_Leave_Sheet__c> submittedList = [
            SELECT Id, Name, Start_Date__c, End_Date__c, Leave_Type__c, Reason__c, Leave_Status__c,
                Applied_Date__c, Half_Day_Period__c, Approver__c, Approver__r.Name, Approval_Date__c,
                Employee__r.Name, Employee__r.Username, Comment__c
            FROM Employee_Leave_Sheet__c
            WHERE Employee__c != null
            AND Leave_Status__c = 'Submitted'
            ORDER BY CreatedDate DESC
        ];

        List<Employee_Leave_Sheet__c> otherList = [
            SELECT Id, Name, Start_Date__c, End_Date__c, Leave_Type__c, Reason__c, Leave_Status__c,
                Applied_Date__c, Half_Day_Period__c, Approver__c, Approver__r.Name, Approval_Date__c,
                Employee__r.Name, Employee__r.Username, Comment__c
            FROM Employee_Leave_Sheet__c
            WHERE Employee__c != null
            AND Leave_Status__c != 'Submitted'
            AND Leave_Status__c != 'Cancelled'
            AND Leave_Status__c != 'Draft'
            ORDER BY CreatedDate DESC
        ];

        List<Employee_Leave_Sheet__c> finalList = new List<Employee_Leave_Sheet__c>();
        finalList.addAll(submittedList);
        finalList.addAll(otherList);
        return finalList;
    }

    

    	@AuraEnabled
	public static void saveSiteVisitImage(String imageData,String parentId, String fileName){
			String base64Prefix = 'data:image/png;base64,';
if (imageData != null && imageData.startsWith(base64Prefix)) {
    String base64Data = imageData.substring(base64Prefix.length());
    Blob imageBlob = EncodingUtil.base64Decode(base64Data);
		
		ContentVersion cv = new ContentVersion();
		cv.Title = fileName;
		cv.PathOnClient = fileName+'.png';
		cv.ContentLocation = 'S';
		cv.VersionData = imageBlob;
		cv.IsMajorVersion = true;
		cv.FirstPublishLocationId = parentId;
		try{
		insert cv;
		}catch(DmlException e){
			System.debug('inserted failed  :'+e.getMessage());
		}

	System.debug('inserted  :'+cv);
		// Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

		// ContentDocumentLink cdl = new ContentDocumentLink();
		// cdl.ContentDocumentId = contentDocId;
		// cdl.LinkedEntityId = parentId; // e.g., Account ID
		// cdl.ShareType = 'V'; // Viewer
		// cdl.Visibility = 'AllUsers';
		// insert cdl;
}

	}

      @AuraEnabled
    public static List<Map<String, Object>> getTaskItem(){
     List<Map<String, Object>> tasklist = new List<Map<String, Object>>();
        Id currentUserId = UserInfo.getUserId();
        //Id contactId = [SELECT Id FROM Contact WHERE User__c = :currentUserId LIMIT 1].Id;
        // Fetching tasks assigned to the current user or created by the current user

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
        
        for (Task t : [
            SELECT Id, Subject, Status, Priority,
            StartDateTime__c, EndDateTime__c, Due_Date_Time__c,IsReminderSet, ReminderDateTime,
            Assigned_By__r.Name, ActivityDate, Owner.Name,
            (SELECT RelationId, Relation.Name FROM TaskRelations WHERE Relation.Type = 'Contact')
        FROM Task
        WHERE Id IN (
            SELECT TaskId FROM TaskRelation WHERE RelationId = :contactId
        ) AND Status != 'Completed' 
        ]) {

             DateTime TODAY = System.now();
             if ((t.EndDateTime__c != null && t.EndDateTime__c.date() <= TODAY.date()  &&  t.EndDateTime__c.date() >=TODAY.addDays(-30)) ) {
            taskList.add(buildTaskMap(t));
        }
        }

         for (Task t : [
            SELECT Id, Subject, Status, Priority,
            StartDateTime__c, EndDateTime__c, Due_Date_Time__c,IsReminderSet, ReminderDateTime,
            Assigned_By__r.Name, ActivityDate, Owner.Name,
            (SELECT RelationId, Relation.Name FROM TaskRelations WHERE Relation.Type = 'Contact')
        FROM Task
        WHERE Status != 'Completed' AND IsReminderSet = true AND OwnerId = :currentUserId
        ]) {

             DateTime TODAY = System.now();
             if (( t.ReminderDateTime != null && t.ReminderDateTime.date() <= TODAY.date() &&  t.ReminderDateTime.date() >=TODAY.addDays(-30)) ) {
            taskList.add(buildTaskMap(t));
        }
        }

        for (Site_Visit__c sv : [
                SELECT Id, Name, Visit_Date__c,Visit_Date_Time__c, Status__c, OwnerId, Owner.Name, Opportunity__r.Name
                FROM Site_Visit__c 
                WHERE Visit_Date__c != NULL AND OwnerId = :currentUserId AND Status__c != 'Completed'
            ]) {
              
             DateTime TODAY = System.now();
             if (sv.Visit_Date__c != null && sv.Visit_Date__c == TODAY.date()) {
           taskList.add(buildProfileSiteVisitMap(sv));
        }
                
            }

        for (Event ev : [
    SELECT Id, Subject, StartDateTime, EndDateTime,
           (SELECT RelationId, Relation.Name FROM EventRelations WHERE Relation.Type = 'Contact')
    FROM Event WHERE Id IN (
            SELECT EventId FROM EventRelation WHERE RelationId = :contactId
    )
]) {
        DateTime TODAY = System.now();
        if (ev.StartDateTime != null && ev.StartDateTime.date() == TODAY.date()) {
    Map<String, Object> eventMap = buildEventMap(ev);
    if (eventMap != null) {
         taskList.add(eventMap);
    }
}
   
}   
         
            
        
        return tasklist;

    }
	  @testVisible
      private static Map<String, Object> buildTaskMap(Task t) {
        Map<String, Object> mapTask = new Map<String, Object>();
        //mapTask.put('id', t.Id);        
        //mapTask.put('title', t.Subject + ' : ' + t.Owner.Name);
        
        String Assigned_By = t.Assigned_By__r.Name != null? ' : '+t.Assigned_By__r.Name :'';
        String EndDate = t.EndDateTime__c != null? ' : ' +t.EndDateTime__c: '';
        if(t.Assigned_By__c == UserInfo.getUserId()){
        mapTask.put('label', t.Subject + ' : ' + t.Owner.Name+EndDate);
        mapTask.put('name', t.Subject + ' : ' + t.Owner.Name+EndDate);
    } else {
        mapTask.put('label', t.Subject +Assigned_By+EndDate);
        mapTask.put('name', t.Subject +Assigned_By+EndDate);
    }
    if(t.IsReminderSet == true){
            mapTask.put('label', t.Subject + ' : ' + t.Owner.Name+' : '+t.ReminderDateTime);
            mapTask.put('name', t.Subject + ' : ' + t.Owner.Name+' : '+t.ReminderDateTime);
        } 
        mapTask.put('type', 'icon');
        mapTask.put('iconName', 'utility:task');
        mapTask.put('isLink', true);
        mapTask.put('href', '/lightning/r/Task/' + t.Id + '/view');
        return mapTask;
    }

     @testVisible
      private static Map<String, Object> buildEventMap(Event t) {
        Map<String, Object> mapEvent = new Map<String, Object>();
        
  
    mapEvent.put('label', 'Event : ' + t.Subject + ' : ' + t.StartDateTime);
    mapEvent.put('name', 'Event : ' + t.Subject + ' : ' + t.StartDateTime);
    mapEvent.put('type', 'icon');
    mapEvent.put('iconName', 'utility:event');
    mapEvent.put('isLink', true);
    mapEvent.put('href', '/lightning/r/Event/' + t.Id + '/view');
    return mapEvent;
}
	@testVisible
     private static Map<String, Object> buildProfileSiteVisitMap(Site_Visit__c sv) {
        Map<String, Object> mapTask = new Map<String, Object>();
        mapTask.put('label', 'Site visit: ' + sv.Opportunity__r.Name+' '+ sv.Visit_Date_Time__c.format('MMM dd, yyyy HH:mm'));
        mapTask.put('name', 'Site visit: ' + sv.Opportunity__r.Name+' '+ sv.Visit_Date_Time__c.format('MMM dd, yyyy HH:mm'));

       mapTask.put('type', 'icon');
        mapTask.put('iconName', 'utility:target');
        mapTask.put('isLink', true);
        mapTask.put('href', '/lightning/r/Task/' + sv.Id + '/view');
        
        return mapTask;
    }

      @AuraEnabled
    public static Boolean getLeaveCount(){
        Date today = System.today();
        List<Employee_Leave_Sheet__c> leaveList =[SELECT Id, Name, Start_Date__c, End_Date__c, Leave_Type__c, Reason__c, Leave_Status__c, Applied_Date__c,Half_Day_Period__c, Approver__c, Approval_Date__c,Employee__r.Name ,Employee__r.Username, Comment__c, Approver__r.Name
            FROM Employee_Leave_Sheet__c
            WHERE Employee__c = :UserInfo.getUserId()
            AND (Leave_Status__c = 'Approved' OR Leave_Status__c = 'Submitted')
            AND Is_Half_Day__c = false
            AND Start_Date__c <= :today
            AND End_Date__c >= :today
            LIMIT 1];
        return !leaveList.isEmpty();
        
    }

}