trigger SiteVisitTrigger on Site_Visit__c (after insert, after update) {

    switch on Trigger.operationType {

        when AFTER_INSERT {
            SiteVisitTriggerHandler.processSiteVisits(Trigger.new, null);
        }

        when AFTER_UPDATE {
            SiteVisitTriggerHandler.processSiteVisits(Trigger.new, Trigger.oldMap);
        }
    }
}