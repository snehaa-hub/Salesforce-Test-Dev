public with sharing class EventCalendarController {
    @AuraEnabled
    public static String createEvent(String eventValues, String selectedUsersJson) {
        Map<String, Object> eventInput = (Map<String, Object>) JSON.deserializeUntyped(eventValues);

        // Parse selected users JSON to a list of maps
        List<Object> selectedUsersList = (List<Object>) JSON.deserializeUntyped(selectedUsersJson);
        System.debug('Selected Users List: ' + selectedUsersList);

        String startRaw = (String) eventInput.get('StartDateTime');
        String endRaw   = (String) eventInput.get('EndDateTime');

        // Replace T with space, remove milliseconds and timezone
        String startStr = startRaw.replace('T', ' ').substring(0, 19);
        String endStr   = endRaw.replace('T', ' ').substring(0, 19);

        // Create the Event
        Event__c evt = new Event__c(
            Subject__c = String.valueOf(eventInput.get('Subject')),
            StartDateTime__c = DateTime.valueOfGmt(startStr),
            EndDateTime__c = DateTime.valueOfGmt(endStr),
            All_Day_Event__c = Boolean.valueOf(eventInput.get('AllDay')),
            OwnerId = UserInfo.getUserId(),
            Location__c = String.valueOf(eventInput.get('Location')),
            Description__c = String.valueOf(eventInput.get('Description'))
        );
        insert evt;

        // Create attendee records
        List<Event_Attendee__c> attendees = new List<Event_Attendee__c>();
        for (Object userObj : selectedUsersList) {
            Map<String, Object> userMap = (Map<String, Object>) userObj;
            attendees.add(new Event_Attendee__c(
                Name = (String) userMap.get('Name'),
                Event__c = evt.Id,
                Event_Attendee__c = (Id) userMap.get('Id')
            ));
        }

        if (!attendees.isEmpty()) {
            insert attendees;
        }

        return evt.Id;
    }
}