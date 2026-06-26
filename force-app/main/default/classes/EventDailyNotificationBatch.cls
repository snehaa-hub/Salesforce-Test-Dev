/**
* @File Name : AWH_EmployeeTrackerController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : Aug 20, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | Aug 20, 2025 |   | Initial Version
**/

public class EventDailyNotificationBatch implements Database.Batchable<SObject>{

    public Database.QueryLocator start(Database.BatchableContext bc ){
         DateTime todayStart = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        return Database.getQueryLocator([
            SELECT Id,
                   Name, CreatedDate,Event_Attendee__c, Event_Attendee__r.Email, Event__r.Id,Event__r.Subject__c, Event__r.StartDateTime__c, Event__r.EndDateTime__c
                  FROM Event_Attendee__c
                   WHERE Event__r.StartDateTime__c >= :todayStart
              AND Event_Attendee__r.Email != null
        ]);
    }
    public void execute(Database.BatchableContext bc,List <Event_Attendee__c> attendeeList ){
        
         String notificationTypeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Event_Notification' LIMIT 1].Id;
		Set<String> recipientId = new Set<String>{ Userinfo.getUserId()};
        for (Event_Attendee__c attendee : attendeeList) {
            if (attendee.Event_Attendee__c != null) {
                recipientId.add(attendee.Event_Attendee__c);
            }
            System.debug('recipientId 21'+ recipientId);
        }
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Event Reminder');
            notification.setBody('You have an event scheduled today.');
            notification.setNotificationTypeId(notificationTypeId);
         
            notification.setTargetId(attendeeList[0].Event__r.Id);
            
           notification.send(recipientId);
        System.debug('notification'+ notification);
        }
       public void finish(Database.BatchableContext bc){
        System.debug('Batch Completed for Event Notifications.');
    }
   

   
}