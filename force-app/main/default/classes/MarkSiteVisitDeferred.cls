/**
 * @description This class is used to mark site visit record as deferred using opportunity Id
 */
public without sharing class MarkSiteVisitDeferred {

    /**
     * @description This class is used to mark site visit record as deferred using opportunity Id
     * @param requestLst
     */
    @InvocableMethod(label='Mark Site Visit Deferred' description='Mark Site Visit Deferred')
    public static void execute(List<Request> requestLst){	
        List<Site_Visit__c> siteVisitListUpdated = new List<Site_Visit__c>();
        Set<String> opportunityIds = new Set<String>();
        for(Request req : requestLst){ 
            if(!String.isBlank(req.opportunityId)){
                opportunityIds.add(req.opportunityId);
            }
        }
        
        String numString = String.join(opportunityIds, '\',\'');
        String status = 'Scheduled';
        
        String siteVisitQuery = 'SELECT Id, Deferred_Reason__c, Status__c FROM Site_Visit__c';      
        if(!opportunityIds.isEmpty()){
            siteVisitQuery = siteVisitQuery + ' WHERE Opportunity__c IN (\''+ String.escapeSingleQuotes(numString) +'\') AND Status__c = \'' + String.escapeSingleQuotes(status) + +'\'';
        }else{
            siteVisitQuery = siteVisitQuery + ' WHERE Status__c = \'' + String.escapeSingleQuotes(status) + +'\'';
        }
        
        List<Site_Visit__c> siteVisitList = database.query(siteVisitQuery);
        
        if(!siteVisitList.isEmpty()){
            for(Site_Visit__c siteVisit: siteVisitList){
                siteVisit.Status__c = 'Deferred';
                siteVisit.Deferred_Reason__c = 'Rescheduled';
                siteVisitListUpdated.add(siteVisit);
            }
        }
        
        if(!siteVisitListUpdated.isEmpty()){
            Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Site_Visit__c;
            Boolean thisUserMayUpdate = drSObj.isUpdateable();
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                        AccessType.UPDATABLE,  siteVisitListUpdated);

            if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
                update securityDecision.getRecords();
            }
        }
    }
    
    /**
     * @description This is request wrapper
     */
    public class Request{
        @InvocableVariable(label = 'Opportunity Id' description = 'Record Id of Opportunity' required = false)
        public String opportunityId;
    }
}