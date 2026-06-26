/**
 * @description This class is used to upsert site visit record with opportunity
 */
public without sharing class UpsertSiteVisit {

/**
 * @description This invocable method is used to upsert site visit record with opportunity
 * @param requestLst
 */
@InvocableMethod(label='Upsert Site Visit' description='Upsert Site Visit')
public static List <Results>  execute(List<Request> requestLst){	
    List<Site_Visit__c> siteVisitList = new List<Site_Visit__c>();

     List<Results> responseWrapper= new List<Results>();
    
    for(Request req : requestLst){ 
        Map<String, Object> siteVisitMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(req.siteVisit));

        if(!String.isBlank(req.opportunityId)){
            siteVisitMap.put('Opportunity__c',req.opportunityId);
        }else{
            Map<String, Object> siteVisitMapToGetData = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(req.siteVisitRecord));
            siteVisitMap.put('Opportunity__c',siteVisitMapToGetData.get('Opportunity__c'));
            siteVisitMap.put('Reschedule_by__c',siteVisitMapToGetData.get('Id'));
        }

        Site_Visit__c siteVisit = (Site_Visit__c) JSON.deserialize(
            JSON.serialize(siteVisitMap), 
            Site_Visit__c.class
        );
        
        siteVisitList.add(siteVisit);
    }
    
    if(!siteVisitList.isEmpty()){
        SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                    AccessType.UPSERTABLE, siteVisitList);
        
            System.debug('securityDecision1'+securityDecision);
        if(!(securityDecision.getRecords()).isEmpty()){
                System.debug('securityDecision'+securityDecision.getRecords());
                List<Site_Visit__c> outputMembers = (List<Site_Visit__c>) securityDecision.getRecords();
            upsert outputMembers;

            Results response = new Results();

    response.outputMember = outputMembers[0];
    
    responseWrapper.add(response);
    
            
        }
    }
    return responseWrapper; 
}

/**
 * @description This is request wrapper
 */
public class Request{

    @InvocableVariable(label = 'Site Visit' description = 'Site Visit' required = true)
    public Site_Visit__c siteVisit;
    
    @InvocableVariable(label = 'Opportunity Id' description = 'Record Id of Opportunity' required = false)
    public String opportunityId;
    
    @InvocableVariable(label = 'Site Visit Record' description = 'Site Visit Record' required = false)
    public Site_Visit__c siteVisitRecord;

    
}
public class Results {
  @InvocableVariable(label='Records for Output' description='yourDescription' required=false)
  public SObject outputMember;
  }

}