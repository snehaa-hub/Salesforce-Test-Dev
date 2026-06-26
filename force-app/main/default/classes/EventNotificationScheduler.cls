global class EventNotificationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
    EventNotificationBatch batch = new EventNotificationBatch();
    Database.executeBatch(batch, 50);
    }
  /*    public void execute(SchedulableContext sc) {

      
        DateTime todayStart = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        DateTime todayEnd = todayStart.addDays(1).addSeconds(-1);

        // Query attendees for events starting today
        List<Event_Attendee__c> attendeeList = [
            SELECT Id,
                   Name, CreatedDate, Event_Attendee__r.Email, Event__r.Id,Event__r.Subject__c, Event__r.StartDateTime__c, Event__r.EndDateTime__c
                  FROM Event_Attendee__c
                   WHERE Event__r.StartDateTime__c >= :todayStart
                AND Event__r.StartDateTime__c <= :todayEnd
              AND Event_Attendee__r.Email != null
        ];

        if (attendeeList.isEmpty()) {
            System.debug('No attendees found for today\'s events.');
            return;
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Event_Attendee__c attendee : attendeeList) {
            
            String recipientEmail = attendee.Event_Attendee__r.Email;

            if (String.isNotBlank(recipientEmail)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { recipientEmail,'rubanprofessional@gmail.com','ramjith126@gmail.com' });
                mail.setSubject('Reminder: Event Today - ' + attendee.Event__r.Subject__c);
                mail.setPlainTextBody(
                    'Hello,\n\n' +
                    'This is a reminder that you have an event scheduled today.\n\n' +
                    'Subject: ' + attendee.Event__r.Subject__c + '\n' +
                    'Start Time: ' + attendee.Event__r.StartDateTime__c + '\n' +
                    'End Time: ' + attendee.Event__r.EndDateTime__c + '\n\n' +
                    'Regards,\nSalesforce System'
                );
                emails.add(mail);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('Sent ' + emails.size() + ' reminder emails to attendees.');
        }
    }*/
}