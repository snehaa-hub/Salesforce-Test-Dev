/**
* @File Name : TaskNoticficationSchedule.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : Aug 25, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | Aug 25, 2025 |   | Initial Version
**/

global class TaskNoticficationSchedule implements Schedulable {
 
    global void execute(SchedulableContext sc) {
        Date today = Date.today();

        // 1. Get today's tasks
        List<Task> taskList = [
            SELECT Id, Subject, Description, ActivityDate, Start_Date__c, End_Date__c,
                   WhoId, Owner.Email, OwnerId
            FROM Task
            WHERE  Start_Date__c = :today
        ];
        if (taskList.isEmpty()) {
            System.debug('No tasks found for reminders.');
            return;
        }

        Map<Id, Task> taskMap = new Map<Id, Task>(taskList);

        // 2. Get TaskWhoRelations (multiple contacts)
        List<TaskWhoRelation> taskWhoList = [
            SELECT TaskId, RelationId, Relation.Email, Relation.FirstName
            FROM TaskWhoRelation
            WHERE TaskId IN :taskMap.keySet()
                  AND Relation.Type = 'Contact'
                  AND Relation.Email != null
        ];

        // 3. Group by Contact Id → tasks
        Map<Id, List<Task>> contactToTasks = new Map<Id, List<Task>>();
        for (TaskWhoRelation twr : taskWhoList) {
            if (!contactToTasks.containsKey(twr.RelationId)) {
                contactToTasks.put(twr.RelationId, new List<Task>());
            }
            contactToTasks.get(twr.RelationId).add(taskMap.get(twr.TaskId));
        }

        // 4. Also handle WhoId (single contact on task)
        for (Task t : taskList) {
            if (t.WhoId != null && String.valueOf(t.WhoId).startsWith('003')) {
                if (!contactToTasks.containsKey(t.WhoId)) {
                    contactToTasks.put(t.WhoId, new List<Task>());
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
            List<Task> tasksForContact = contactToTasks.get(cId);

            String body = 'Hello ' + (c.FirstName != null ? c.FirstName : '') + ',<br/><br/>Here are your tasks for today:<br/><ul>';
            for (Task t : tasksForContact) {
                body += '<li><b>' + t.Subject + '</b>'
                     + (t.Start_Date__c != null ? ' (Start: ' + t.Start_Date__c + ')' : '')
                     + (t.End_Date__c != null ? ' (End: ' + t.End_Date__c + ')' : '')
                     + '<br/>' + (t.Description != null ? t.Description : '') + '</li>';
            }
            body += '</ul><br/>Thanks,<br/>Your Salesforce System';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { c.Email });
            mail.setSubject('Your Tasks for ' + today.format());
            mail.setHtmlBody(body);

            emails.add(mail);
        }

       

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('Sent ' + emails.size() + ' reminder emails.');
        }
    }
}