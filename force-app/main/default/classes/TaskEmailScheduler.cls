global class TaskEmailScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date today = Date.today();

     
        DateTime todayStart = DateTime.newInstance(today, Time.newInstance(0,0,0,0));
        DateTime todayEnd = DateTime.newInstance(today.addDays(1), Time.newInstance(0,0,0,0));

        List<Task> tasksDueToday = [
            SELECT Id, Subject, Due_Date_Time__c, OwnerId, Owner.Email,Assigned_By__c, Assigned_By__r.Email
            FROM Task
            WHERE Due_Date_Time__c >= :todayStart
            AND Due_Date_Time__c < :todayEnd
        ]; 

        Set<Id> assignedByIds = new Set<Id>();
        for (Task t : tasksDueToday) {
            if (t.Assigned_By__c != null) {
                assignedByIds.add(t.Assigned_By__c);
            }
        }


         Map<Id, User> assignedByUserMap = new Map<Id, User>(
            [SELECT Id, Name, Email FROM User WHERE Id IN :assignedByIds]
        );

        for(Task t : tasksDueToday){
    if(t.Assigned_By__c != null && assignedByUserMap.containsKey(t.Assigned_By__c)){
        User assignedByUser = assignedByUserMap.get(t.Assigned_By__c);
        if(assignedByUser.Email != null){
            TaskEmailHelper.sendTaskEmail(t,assignedByUser);
        }
    }
}

      
        DateTime tomorrowStart = DateTime.newInstance(today.addDays(1), Time.newInstance(0,0,0,0));

        List<Task> futureTasks = [
            SELECT Id, Subject, Due_Date_Time__c, OwnerId, Owner.Email,Assigned_By__c, Assigned_By__r.Email
            FROM Task
            WHERE Due_Date_Time__c >= :tomorrowStart
        ];

            Set<Id> futureOwnerIds = new Set<Id>();
        for (Task t : futureTasks) {
            if (t.Assigned_By__c != null) {
                futureOwnerIds.add(t.Assigned_By__c);
            }
        }

        Map<Id, User> futureAssignedByUserMap = new Map<Id, User>(
            [SELECT Id, Name, Email FROM User WHERE Id IN :futureOwnerIds]
        );


        for(Task t : futureTasks){
    if(t.Assigned_By__c != null && futureAssignedByUserMap.containsKey(t.Assigned_By__c)){
        DateTime dueDateTime = t.Due_Date_Time__c;
        DateTime eightAM = DateTime.newInstance(dueDateTime.date(), Time.newInstance(9,0,0,0));
        String jobName = 'TaskEmail8AM_' + t.Id;
        try {
            System.schedule(jobName, getCronExpression(eightAM), new Task8AMEmailSender(t));
        } catch(Exception e){
            System.debug('Error scheduling job: ' + e.getMessage());
        }
    }
}

    }

    private String getCronExpression(DateTime dt) {
      
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



// global class TaskEmailScheduler implements Schedulable {
//     global void execute(SchedulableContext sc) {
//         Date today = Date.today();

//         DateTime todayStart = DateTime.newInstance(today, Time.newInstance(0,0,0,0));
//         DateTime todayEnd = DateTime.newInstance(today.addDays(1), Time.newInstance(0,0,0,0));

//         List<Task> tasksDueToday = [
//             SELECT Id, Subject, Due_Date_Time__c, OwnerId, Owner.Email, Assigned_By__c
//             FROM Task
//             WHERE Due_Date_Time__c >= :todayStart
//             AND Due_Date_Time__c < :todayEnd
//         ]; 


//         Set<Id> assignedByIds = new Set<Id>();
//         for (Task t : tasksDueToday) {
//             if (t.Assigned_By__c != null) {
//                 assignedByIds.add(t.Assigned_By__c);
//             }
//         }


//          Map<Id, User> assignedByUserMap = new Map<Id, User>(
//             [SELECT Id, Name, Email FROM User WHERE Id IN :assignedByIds]
//         );
//         for(Task t : tasksDueToday){
            
//             TaskEmailHelper.sendTaskEmail(t, assignedByUserMap.get(t.Assigned_By__c));
        
            
//         }

//         DateTime tomorrowStart = DateTime.newInstance(today.addDays(1), Time.newInstance(0,0,0,0));

//         List<Task> futureTasks = [
//             SELECT Id, Subject, Due_Date_Time__c, OwnerId, Owner.Email, Assigned_By__c
//             FROM Task
//             WHERE Due_Date_Time__c >= :tomorrowStart
//         ];

//         for(Task t : futureTasks){
//             if(t.Due_Date_Time__c != null){
//                 DateTime dueDateTime = t.Due_Date_Time__c;
//                 DateTime eightAM = DateTime.newInstance(dueDateTime.date(), Time.newInstance(8,0,0,0));
//                 String jobName = 'TaskEmail9AM_' + t.Id;
//                 try {
//                     System.schedule(jobName, getCronExpression(eightAM), new Task8AMEmailSender(t));
//                 } catch(Exception e){
//                     System.debug('Error scheduling job: ' + e.getMessage());
//                 }
//             }
//         }
//     }

//     private String getCronExpression(DateTime dt) {
        
//         return String.format('{0} {1} {2} {3} {4} ? {5}', new String[] {
//             String.valueOf(dt.second()),
//             String.valueOf(dt.minute()),
//             String.valueOf(dt.hour()),
//             String.valueOf(dt.day()),
//             String.valueOf(dt.month()),
//             String.valueOf(dt.year())
//         });
//     }
// }