global class ReminderEmailJob implements Schedulable {
    global Id taskId;

    global ReminderEmailJob(Id taskId) {
        this.taskId = taskId;
    }

    global void execute(SchedulableContext sc) {
        Task t = [
            SELECT Id, Subject, Due_Date_Time__c, Assigned_By__c, Assigned_By__r.Name, Assigned_By__r.Email
            FROM Task
            WHERE Id = :taskId
            LIMIT 1
        ];

        if(t.Assigned_By__r.Email != null){
            String dueDateFormatted = t.Due_Date_Time__c != null
                ? t.Due_Date_Time__c.format('MMMM dd, yyyy hh:mm a')
                : 'No due date/time';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { t.Assigned_By__r.Email });
            email.setSubject('Task Reminder');

            String body = 'Hi ' + t.Assigned_By__r.Name + ',\n\n' +
                          'You have the scheduled task:\n\n' +
                          'Subject: ' + t.Subject + '\n' +
                          'Due Date/Time: ' + dueDateFormatted + '\n\n' +
                          'Thank you.';

            email.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
}