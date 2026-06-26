public class LeadTriggerHandler {
    public static void beforeInsert(List<Lead> newLeadList) {
        
        for(Lead leadInstance : newLeadList) {
            
               leadInstance.LastName = leadInstance.Name__c;
            
           
        }
    }
}