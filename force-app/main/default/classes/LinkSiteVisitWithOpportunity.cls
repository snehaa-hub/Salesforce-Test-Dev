/**
 * @description This class is used to link site visit record with opportunity on enquiry conversion
 */
public without sharing class LinkSiteVisitWithOpportunity {

    /**
     * @description This invocable method is used to link site visit record with opportunity on enquiry conversion
     * @param requestLst
     */
    @InvocableMethod(label='Link Site Visit With Opportunity' description='Link Site Visit With Opportunity')
    public static void execute(List<Request> requestLst){	
        Map<String,String> requestMap =new Map<String,String>();
        for(Request req : requestLst){ 
            requestMap.put(req.enquiryId,req.opportunityId);
        }
        
        if(!requestMap.isEmpty()){
            List<Site_Visit__c> siteVisitList = new List<Site_Visit__c>();
            SObjectAccessDecision decision = Security.stripInaccessible(
                                        AccessType.READABLE,
                                        [SELECT Id, Enquiry__c
                                            FROM Site_Visit__c
                                            WHERE Enquiry__c In: requestMap.keySet()]);

            if(!(decision.getRecords()).isEmpty()) {
                for(Site_Visit__c siteVisit: (List<Site_Visit__c>) decision.getRecords()){

                    Map<String, Object> siteVisitMap = new Map<String, Object>();
                    siteVisitMap.put('Id',siteVisit.Id);
                    siteVisitMap.put('Opportunity__c',requestMap.get(siteVisit.Enquiry__c));

                    Site_Visit__c siteVisitToUpdate = (Site_Visit__c) JSON.deserialize(
                        JSON.serialize(siteVisitMap), 
                        Site_Visit__c.class
                    );

                    siteVisitList.add(siteVisitToUpdate);
                }
            }

            if(!siteVisitList.isEmpty()){
                Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Site_Visit__c;
                Boolean thisUserMayUpdate = drSObj.isUpdateable();
                SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                            AccessType.UPDATABLE,  siteVisitList);

                if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
                    update securityDecision.getRecords();
                }
            }
        }
    }
    
    /**
     * @description This is request wrapper
     */
    public class Request{
        @InvocableVariable(label = 'Enquiry Id' description = 'Record Id of Enquiry' required = true)
        public String enquiryId;
        
        @InvocableVariable(label = 'Opportunity Id' description = 'Record Id of Opportunity' required = true)
        public String opportunityId;
    }
}