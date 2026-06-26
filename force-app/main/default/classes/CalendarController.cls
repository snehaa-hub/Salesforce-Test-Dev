public class CalendarController {
	@AuraEnabled(cacheable=true)
    public static List<Task> getTasks() {
        return [SELECT Id, Subject, ActivityDate, Status, Priority, WhatId, What.Name, ReminderDateTime, 
                       IsReminderSet, OwnerId,Owner.Name, Assigned_By__c,Assigned_By__r.Name, Due_Date_Time__c
                       FROM Task WHERE Due_Date_Time__c != null];
    }

    @AuraEnabled(cacheable=true)
    public static List<Site_Visit__c> getSiteVisits() {
        return [SELECT Id, Name, Visit_Date__c FROM Site_Visit__c WHERE Visit_Date__c != NULL];
    }
}