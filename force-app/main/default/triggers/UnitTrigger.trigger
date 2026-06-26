trigger UnitTrigger on Unit__c (before insert,before update,after insert,after update) {
  if(Trigger.isAfter)
   {
       if(Trigger.isInsert)
       {
           UnitTriggerHandler.GeoCoordinatesExtractor(trigger.New,null);
           UnitTriggerHandler.interestEnquiriesNotification(trigger.New,null);
           UnitTriggerHandler.checkDuplicateNewUnit(trigger.New);
       }
       if(Trigger.isUpdate)
       {
           UnitTriggerHandler.GeoCoordinatesExtractor(trigger.New,trigger.oldMap);
           UnitTriggerHandler.interestEnquiriesNotification(trigger.New,trigger.oldMap);
           UnitTriggerHandler.checkDuplicateNewUnit(trigger.New);
       }
   }

   if(Trigger.isBefore)
   {
       if(Trigger.isInsert)
       {
           UnitTriggerHandler.checkDuplicateUnitBeforeInsert(trigger.New,null);
        
          
       }
       if(Trigger.isUpdate)
       {
          UnitTriggerHandler.checkDuplicateUnitBeforeInsert(trigger.New,trigger.oldMap);
       }
   }

}