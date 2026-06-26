public class SendTaskAndEventEmail {

    @AuraEnabled
    public static String sendEmails(String taskInfo, String selectedUsers, String objectName) {
        System.debug('selectedUsers: ' + selectedUsers);
        
        // Deserialize taskInfo
        Map<String, Object> taskMap = (Map<String, Object>) JSON.deserializeUntyped(taskInfo);
        System.debug('taskMap ---> ' + taskMap);
        
        String subjectLine = (String) taskMap.get('Subject');
        String startDate = String.valueOf(taskMap.get('StartDate'));
        String endDate = String.valueOf(taskMap.get('EndDate'));
        String objName = objectName;
        
        String startTimeStr = String.valueOf(taskMap.get('StartTime')); // e.g. "15:00:00.000"
        String endTimeStr   = String.valueOf(taskMap.get('EndTime'));   // e.g. "17:30:00.000"
		
        String formattedStartTime = convertTo12HrFormat(startTimeStr);
		String formattedEndTime   = convertTo12HrFormat(endTimeStr);
        // Deserialize users safely
        List<Object> usersObjList = (List<Object>) JSON.deserializeUntyped(selectedUsers);
        List<Map<String, Object>> usersList = new List<Map<String, Object>>();
        for (Object o : usersObjList) {
            usersList.add((Map<String, Object>) o);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Map<String, Object> u : usersList) {
            String userName = (String) u.get('Name');
            String userEmail = (String) u.get('Email');

            if (String.isBlank(userEmail)) continue; // Skip invalid emails

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{userEmail});
            
            // Subject line
            mail.setSubject(
                (objName == 'task' ? 'Task Assigned: ' : 'New Event Scheduled: ') + subjectLine
            );

            // Body content (using 12-hour formatted times)
            String body = 'Hello ' + userName + ',\n\n' +
                          'You have ' + objName + ' scheduled:\n\n' +
                          'Subject: ' + subjectLine + '\n' +
                          'Start Date: ' + startDate + ' : Start Time: ' + formattedStartTime + '\n' +
                          'End Date: ' + endDate + ' : End Time: ' + formattedEndTime + '\n\n' +
                          'Regards,\nPooja Bagri.';

            System.debug('Email Body: ' + body);

            mail.setPlainTextBody(body);
            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
        return 'Email(s) sent successfully.';
    }

    public static String convertTo12HrFormat(String timeStr) {
    if (String.isBlank(timeStr)) return '';

    // Remove milliseconds if present
    if (timeStr.contains('.')) {
        timeStr = timeStr.split('\\.')[0];
    }

    List<String> parts = timeStr.split(':');
    if (parts.size() < 2) return timeStr;

    Integer hour = Integer.valueOf(parts[0]);
    Integer minute = Integer.valueOf(parts[1]);

    String ampm = (hour >= 12) ? 'PM' : 'AM';
    if (hour == 0) {
        hour = 12;
    } else if (hour > 12) {
        hour -= 12;
    }

    // Build the string manually — no String.format needed
    String hourStr = (hour < 10) ? '0' + String.valueOf(hour) : String.valueOf(hour);
    String minuteStr = (minute < 10) ? '0' + String.valueOf(minute) : String.valueOf(minute);

    return hourStr + ':' + minuteStr + ' ' + ampm;
}

}