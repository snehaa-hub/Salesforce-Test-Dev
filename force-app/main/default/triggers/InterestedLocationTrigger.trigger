trigger InterestedLocationTrigger on Interested_Locations__c (after insert,After update) {
    if(trigger.IsAfter && (trigger.IsInsert || trigger.IsUpdate)){
        InterestedLocationGeoController.getGeoupdateMethod(trigger.new);
    }
}