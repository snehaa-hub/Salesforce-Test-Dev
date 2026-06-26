public class TaskEmailHelper {
    public static void sendTaskEmail(Task task,User assignedByUser) {
        if (task.Assigned_By__c == null) {
            System.debug('No Assigned_By__c user on the task.');
            return;
        }

        //User assignedByUser = [SELECT Id, Name, Email FROM User WHERE Id = :task.Assigned_By__c LIMIT 1];

        if (String.isBlank(assignedByUser.Email)) {
            System.debug('Assigned_By__c user does not have an email.');
            return;
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { assignedByUser.Email });
        email.setSubject('Task You Assigned is Due');

        String dueDateFormatted = task.Due_Date_Time__c != null 
            ? task.Due_Date_Time__c.format('MMMM dd, yyyy hh:mm a') 
            : 'No due date/time';

        String body = 'Hi ' + assignedByUser.Name + ',\n\n' +
                      'A task you created is due.\n\n' +
                      'Subject: ' + task.Subject + '\n' +
                      'Due Date/Time: ' + dueDateFormatted + '\n\n' +
                      'Thank you.';

        email.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }



    

}