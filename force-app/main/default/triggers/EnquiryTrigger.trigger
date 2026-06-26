trigger EnquiryTrigger on Enquiry__c (after insert, after update) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        EnquiryObject.createOpportunities(Trigger.new);
      //  EnquiryTriggerHandler.sendEnquiryNotification(Trigger.new);
    }
    if(Trigger.isAfter &&  Trigger.isUpdate){
        EnquiryObject.createOpportunities(Trigger.new);
    }
}