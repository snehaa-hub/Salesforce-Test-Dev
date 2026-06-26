global class RNRFollowUpBatch implements Database.Batchable<SObject>, Schedulable {

    // =========================
    //  SCHEDULER
    // =========================
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new RNRFollowUpBatch(), 200);
    }

    // =========================
    //  START METHOD
    // =========================
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Status__c, CreatedDate, LastModifiedById
            FROM Enquiry__c
            WHERE Status__c = 'RNR'
        ]);
    }

    // =========================
    // EXECUTE METHOD
    // =========================
    global void execute(Database.BatchableContext bc, List<Enquiry__c> scope) {

        List<Task> tasksToInsert = new List<Task>();
        List<Enquiry__c> enquiriesToUpdate = new List<Enquiry__c>();
        

        // Valid follow-up days
        Set<Integer> validDays = new Set<Integer>{1, 2, 3, 5, 7, 10, 14};

        // Map for duplicate check
        Map<Id, Set<Integer>> enquiryTaskDaysMap = new Map<Id, Set<Integer>>();

        Map<Id, Enquiry__c> enquiryMap = new Map<Id, Enquiry__c>();


        // Collect Enquiry IDs
        Set<Id> enquiryIds = new Set<Id>();
        for (Enquiry__c e : scope) {
            enquiryIds.add(e.Id);

            enquiryMap.put(e.Id, e);    
        }

        //   Get Notification Type (ONLY ONCE)
        Id notificationTypeId = [
            SELECT Id FROM CustomNotificationType 
            WHERE DeveloperName = 'RNR_Task_Notification' 
            LIMIT 1
        ].Id;


        // =========================
        // FETCH EXISTING TASKS
        // =========================
        if (!enquiryIds.isEmpty()) {
            for (Task t : [
                SELECT Id, WhatId, Follow_Up_Day__c,Subject
                FROM Task
                WHERE WhatId IN :enquiryIds
                AND Follow_Up_Day__c IN :validDays
            ]) {
                if (!enquiryTaskDaysMap.containsKey(t.WhatId)) {
                    enquiryTaskDaysMap.put(t.WhatId, new Set<Integer>());
                }

                enquiryTaskDaysMap.get(t.WhatId)
                    .add(Integer.valueOf(t.Follow_Up_Day__c));
            }
        }

         Map<Id, Boolean> enquiryHasTodayTask = new Map<Id, Boolean>();

        Date todayDate = Date.today();

        for (Task t : [
            SELECT Id, WhatId, CreatedDate
            FROM Task
            WHERE WhatId IN :enquiryIds
        ]) {
            if (t.CreatedDate.date() == todayDate) {
                enquiryHasTodayTask.put(t.WhatId, true);
            }
        }


        // =========================
        //  PROCESS ENQUIRIES
        // =========================
        for (Enquiry__c e : scope) {

            if (enquiryHasTodayTask.containsKey(e.Id)) {
                continue;
            }

            Integer dayCount;

            if (!enquiryTaskDaysMap.containsKey(e.Id)) {
                dayCount = 1;
            } else {

                Set<Integer> existingDays = enquiryTaskDaysMap.get(e.Id);

                Integer maxDay = 0;
                for (Integer d : existingDays) {
                    if (d > maxDay) {
                        maxDay = d;
                    }
                }

                // Ordered follow-up days
                List<Integer> orderedDays = new List<Integer>{1,2,3,5,7,10,14};

                Integer nextDay;

                for (Integer d : orderedDays) {
                    if (d > maxDay) {
                        nextDay = d;
                        break;
                    }
                }

                if (nextDay == null) {
                    continue;
                }

                dayCount = nextDay;
            }

            // Duplicate check
            if (enquiryTaskDaysMap.containsKey(e.Id) &&
                enquiryTaskDaysMap.get(e.Id).contains(dayCount)) {
                continue;
            }

            Task task = new Task();
            task.Subject = 'Day ' + dayCount + ' – ' + e.Name;
            task.Status = 'Not Started';
            task.WhatId = e.Id;
            task.Type = 'Follow-Up';
            task.Follow_Up_Day__c = dayCount;
            task.ActivityDate = Date.today();

            task.OwnerId = (e.LastModifiedById != null) 
                ? e.LastModifiedById 
                : UserInfo.getUserId();

            tasksToInsert.add(task);

            if (dayCount == 14) {
                e.Status__c = 'Closed';
                enquiriesToUpdate.add(e);
            }
        }
        // =========================
        //  INSERT TASKS
        // =========================
       if (!tasksToInsert.isEmpty()) {

    insert tasksToInsert;

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    String baseUrl = URL.getOrgDomainUrl().toExternalForm();

    //Collect Owner IDs
    Set<Id> ownerIds = new Set<Id>();
    for (Task t : tasksToInsert) {
        ownerIds.add(t.OwnerId);
    }

    //Query User Emails
    Map<Id, User> userMap = new Map<Id, User>(
        [SELECT Id, Email FROM User WHERE Id IN :ownerIds]
    );

    //Loop tasks
    for (Task t : tasksToInsert) {

        Enquiry__c e = enquiryMap.get(t.WhatId);
        Integer dayCount = Integer.valueOf(t.Follow_Up_Day__c);

        // =========================
        //EMAIL
        // =========================
        User u = userMap.get(t.OwnerId);

        if (u != null && u.Email != null) {

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new List<String>{u.Email});
            mail.setSaveAsActivity(false);
            mail.setSubject('Follow-Up Task Created - Day ' + dayCount);

            mail.setPlainTextBody(
                'Hello,\n\n' +
                'A follow-up task has been created for you.\n\n' +
                'Enquiry Name: ' + e.Name + '\n' +
                'Follow-Up Day: ' + dayCount + '\n' +
                'Due Date: ' + t.ActivityDate + '\n' +
                'Task Link: ' + baseUrl + '/' + t.Id + '\n\n' +
                'Please take action.'
            );

            emails.add(mail);
        }

        // =========================
        // BELL NOTIFICATION
        // =========================
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('New Follow-Up Task');
        notification.setBody('Day ' + dayCount + ' follow-up for ' + e.Name);
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(t.Id);
        notification.send(new Set<String>{t.OwnerId});
    }

    //SEND EMAILS
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
        System.debug('Emails size: ' + emails.size());
    }
}

        // =========================
        // UPDATE ENQUIRIES
        // =========================
        if (!enquiriesToUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(enquiriesToUpdate, false);

            Integer successCount = 0;
            Integer failCount = 0;

            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    successCount++;
                } else {
                    failCount++;
                    System.debug(' Enquiry Update Error: ' + results[i].getErrors()[0].getMessage());
                }
            }

            System.debug(' Enquiries Closed: ' + successCount + ' | Failed: ' + failCount);
        }
    }

    // =========================
    //  FINISH METHOD
    // =========================
    global void finish(Database.BatchableContext bc) {

        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedDate
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];

        System.debug('========================================');
        System.debug('RNR Follow-Up Batch Completed');
        System.debug('Status: ' + job.Status);
        System.debug('Processed: ' + job.JobItemsProcessed + '/' + job.TotalJobItems);
        System.debug('Errors: ' + job.NumberOfErrors);
        System.debug('Started At: ' + job.CreatedDate);
        System.debug('========================================');
    }
}