/**
* @File Name : Task8AMEmailSender.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 23, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 23, 2025 |   | Initial Version
**/

global class Task8AMEmailSender implements Schedulable {
    global Task taskId;

    global Task8AMEmailSender(Task taskId) {
        this.taskId = taskId;
    }

    global void execute(SchedulableContext sc) {
     

        User assignedByUser = [SELECT Id, Name, Email FROM User WHERE Id = :taskId.Assigned_By__c LIMIT 1];
        TaskEmailHelper.sendTaskEmail(taskId, assignedByUser);
    }
}


// global class Task8AMEmailSender implements Schedulable {
//     global Id taskId;

//     global Task8AMEmailSender(Task task) {
//         this.taskId = task.Id;
//     }

//     global void execute(SchedulableContext sc) {
        
//         Task t = [SELECT Id, Subject, Due_Date_Time__c, Assigned_By__c FROM Task WHERE Id = :taskId LIMIT 1];

//         if (t.Assigned_By__c != null) {
            
//             User assignedByUser = [SELECT Id, Name, Email FROM User WHERE Id = :t.Assigned_By__c LIMIT 1];

           
//             TaskEmailHelper.sendTaskEmail(t, assignedByUser);
//         }
//     }
// }