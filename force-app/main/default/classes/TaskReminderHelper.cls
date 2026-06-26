public class TaskReminderHelper {
    public static Messaging.SingleEmailMessage createEmailForTask(Task t) {
        if (t.Assigned_By__r != null && t.Assigned_By__r.Email != null) {
            String dueDateFormatted = t.Due_Date_Time__c != null
                ? t.Due_Date_Time__c.format('MMMM dd, yyyy hh:mm a')
                : 'No due date/time';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { t.Assigned_By__r.Email });
            email.setSubject('Task Reminder');

            String body = 'Hi ' + t.Assigned_By__r.Name + ',\n\n' +
                          '📋 You have the scheduled task:\n\n' +
                          '📝 Subject: ' + t.Subject + '\n\n' +
                          '⏰ Due Date/Time: ' + dueDateFormatted + '\n\n' +
                          'Thank you.';

            email.setPlainTextBody(body);
            return email;
        }
        return null;
    }
}