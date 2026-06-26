trigger LeadTrigger on Lead (before insert) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.beforeInsert(trigger.new);
        }
    }

}