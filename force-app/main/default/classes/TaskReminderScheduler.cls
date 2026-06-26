global class TaskReminderScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {

        Date today = System.today();
        DateTime startOfDay = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0));
        DateTime endOfDay = DateTime.newInstance(today, Time.newInstance(23, 59, 59, 999));

        List<Task> tasksWithReminders = [
            SELECT Id, Subject, ReminderDateTime, Due_Date_Time__c, Assigned_By__c, Assigned_By__r.Email, Assigned_By__r.Name
            FROM Task
            WHERE Due_Date_Time__c != null
            AND Due_Date_Time__c >= :startOfDay
            AND Due_Date_Time__c <= :endOfDay
            AND Assigned_By__c != null
        ];

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (Task t : tasksWithReminders) {
            Messaging.SingleEmailMessage email = TaskReminderHelper.createEmailForTask(t);
            if (email != null) {
                emailsToSend.add(email);
            }
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
}