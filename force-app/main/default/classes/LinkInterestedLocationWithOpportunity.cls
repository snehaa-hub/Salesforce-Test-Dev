/**
 * @description This class is used to link interested location record with opportunity on enquiry conversion
 */
public without sharing class LinkInterestedLocationWithOpportunity {

    /**
     * @description This invocable method is used to link  interested location record with opportunity on enquiry conversion
     * @param requestLst
     */
    @InvocableMethod(label='Link Interested Location With Opportunity' description='Link Interested Location With Opportunity')
    public static void execute(List<Request> requestLst){	
        Map<String,String> requestMap =new Map<String,String>();
        for(Request req : requestLst){ 
            requestMap.put(req.enquiryId,req.opportunityId);
        }
        
        if(!requestMap.isEmpty()){
            List<Interested_Locations__c> interestedLocationList = new List<Interested_Locations__c>();
            SObjectAccessDecision decision = Security.stripInaccessible(
                                        AccessType.READABLE,
                                        [SELECT Id, Related_Enquiry__c
                                            FROM Interested_Locations__c
                                            WHERE Related_Enquiry__c In: requestMap.keySet()]);

            if(!(decision.getRecords()).isEmpty()) {
                for(Interested_Locations__c interestedLocation: (List<Interested_Locations__c>) decision.getRecords()){

                    Map<String, Object> interestedLocationMap = new Map<String, Object>();
                    interestedLocationMap.put('Id',interestedLocation.Id);
                    interestedLocationMap.put('Related_Opportunity__c',requestMap.get(interestedLocation.Related_Enquiry__c));

                    Interested_Locations__c interestedLocationToUpdate = (Interested_Locations__c) JSON.deserialize(
                        JSON.serialize(interestedLocationMap), 
                        Interested_Locations__c.class
                    );

                    interestedLocationList.add(interestedLocationToUpdate);
                }
            }

            if(!interestedLocationList.isEmpty()){
                Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Interested_Locations__c;
                Boolean thisUserMayUpdate = drSObj.isUpdateable();
                SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                            AccessType.UPDATABLE,  interestedLocationList);

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