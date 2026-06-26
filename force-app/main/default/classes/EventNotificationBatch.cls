global class EventNotificationBatch implements Schedulable {
     global void execute(SchedulableContext sc) {
        DateTime todayStart = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));

        // 1. Get today's tasks
        List<Event> taskList = [
            SELECT Id,  StartDateTime,EndDateTime ,WhoId 
            FROM Event
            WHERE  StartDateTime = :todayStart
        ];
        if (taskList.isEmpty()) {
            System.debug('No tasks found for reminders.');
            return;
        }

        Map<Id, Event> taskMap = new Map<Id, Event>(taskList);

        // 2. Get TaskWhoRelations (multiple contacts)
        List<EventWhoRelation> taskWhoList = [
            SELECT EventId, RelationId, Relation.Email, Relation.FirstName
            FROM EventWhoRelation
            WHERE EventId IN :taskMap.keySet()
                  AND Relation.Type = 'Contact'
                  AND Relation.Email != null
        ];

        // 3. Group by Contact Id → tasks
        Map<Id, List<Event>> contactToTasks = new Map<Id, List<Event>>();
        for (EventWhoRelation twr : taskWhoList) {
            if (!contactToTasks.containsKey(twr.RelationId)) {
                contactToTasks.put(twr.RelationId, new List<Event>());
            }
            contactToTasks.get(twr.RelationId).add(taskMap.get(twr.EventId));
        }

        // 4. Also handle WhoId (single contact on task)
        for (Event t : taskList) {
            if (t.WhoId != null && String.valueOf(t.WhoId).startsWith('003')) {
                if (!contactToTasks.containsKey(t.WhoId)) {
                    contactToTasks.put(t.WhoId, new List<Event>());
                }
                contactToTasks.get(t.WhoId).add(t);
            }
        }

        // 5. Get contacts with emails
        List<Contact> contacts = [
            SELECT Id, Email, FirstName
            FROM Contact
            WHERE Id IN :contactToTasks.keySet() AND Email != null
        ];
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contacts);

        // 6. Build emails
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Id cId : contactToTasks.keySet()) {
            if (!contactMap.containsKey(cId)) continue;
            Contact c = contactMap.get(cId);
            List<Event> tasksForContact = contactToTasks.get(cId);

            String body = 'Hello ' + (c.FirstName != null ? c.FirstName : '') + ',<br/><br/>Here are your tasks for today:<br/><ul>';
            for (Event t : tasksForContact) {
                body += '<li><b>' + t.Subject + '</b>'
                     + (t.StartDateTime != null ? ' (Start: ' + t.StartDateTime + ')' : '')
                     + (t.EndDateTime != null ? ' (End: ' + t.EndDateTime + ')' : '')
                     + '<br/>' + (t.Description != null ? t.Description : '') + '</li>';
            }
            body += '</ul><br/>Thanks,<br/>Your Salesforce System';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { c.Email });
            mail.setSubject('Your Tasks for ' );
            mail.setHtmlBody(body);

            emails.add(mail);
        }

       

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('Sent ' + emails.size() + ' reminder emails.');
        }
    }
}
    /*public Database.QueryLocator start(Database.BatchableContext bc){
		
         DateTime todayStart = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
         DateTime todayEnd = todayStart.addDays(1).addSeconds(-1);
        return Database.getQueryLocator([
            SELECT Id,
                   Name, CreatedDate, Event_Attendee__r.Email, Event__r.Id,Event__r.Subject__c, Event__r.StartDateTime__c, Event__r.EndDateTime__c
                  FROM Event_Attendee__c
                   WHERE Event__r.StartDateTime__c >= :todayStart
                AND Event__r.StartDateTime__c <= :todayEnd
              AND Event_Attendee__r.Email != null
            
        ]);
    }
    public void execute(Database.BatchableContext bc, List<Event_Attendee__c> attendeeList){
        
         List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Event_Attendee__c attendee : attendeeList) {
            
            String recipientEmail = attendee.Event_Attendee__r.Email;
           
            
            String startDtIST = attendee.Event__r.StartDateTime__c.format('yyyy-MM-dd HH:mm:ss', 'Asia/Kolkata');
            String endDtIST = attendee.Event__r.EndDateTime__c.format('yyyy-MM-dd HH:mm:ss', 'Asia/Kolkata');
            System.debug('StartDateTime in IST: ' + startDtIST);
            if (String.isNotBlank(recipientEmail)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { recipientEmail,'rubanprofessional@gmail.com','ramjith126@gmail.com' });
                mail.setSubject('Reminder: Event Today - ' + attendee.Event__r.Subject__c);
                mail.setPlainTextBody(
                    'Hello,\n\n' +
                    'This is a reminder that you have an event scheduled today.\n\n' +
                    'Subject: ' + attendee.Event__r.Subject__c + '\n' +
                    'Start Time: ' + startDtIST + '\n' +
                    'End Time: ' + endDtIST + '\n\n' +
                    'Regards,\nSalesforce System'
                );
                emails.add(mail);
            }
        }
		if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('Sent ' + emails.size() + ' reminder emails.');
        }
    }
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch Completed for Event Notifications.');
    }*/