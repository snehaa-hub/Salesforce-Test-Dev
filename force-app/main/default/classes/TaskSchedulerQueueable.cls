public class TaskSchedulerQueueable implements Queueable {
    private List<Id> taskIds;

    public TaskSchedulerQueueable(List<Id> taskIds){
        this.taskIds = taskIds;
    }

    public void execute(QueueableContext context){
        List<Task> tasksWithReminders = [
            SELECT Id, Subject, ReminderDateTime, Due_Date_Time__c, Assigned_By__c
            FROM Task
            WHERE Id IN :taskIds
        ];

        for(Task t : tasksWithReminders){
            DateTime reminderTime = DateTime.newInstance(t.ReminderDateTime.date(), Time.newInstance(9, 15, 0, 0));
            String jobName = 'ReminderEmail_' + t.Id + '_' + DateTime.now().getTime();

            try {
                System.schedule(jobName, getCronExpression(reminderTime), new ReminderEmailJob(t.Id));
            } catch(Exception e) {
                System.debug('Error scheduling reminder for Task Id: ' + t.Id + ' - ' + e.getMessage());
            }
        }
    }

    private static String getCronExpression(DateTime dt){
        return String.format('{0} {1} {2} {3} {4} ? {5}', new String[] {
            String.valueOf(dt.second()),
            String.valueOf(dt.minute()),
            String.valueOf(dt.hour()),
            String.valueOf(dt.day()),
            String.valueOf(dt.month()),
            String.valueOf(dt.year())
        });
    }
}