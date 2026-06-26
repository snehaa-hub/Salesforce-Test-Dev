/**
 * @description This class is used to upsert a record with opportunity field field dynamically
 */
public without sharing class UpsertRecordWithOpportunity {

    /**
     * @description This invocable method is used to upsert a record with opportunity field field dynamically
     * @param requestLst
     * @return List<Reponse>
     */
    @InvocableMethod(label='Upsert Record With Opportunity' description='Upsert Record With Opportunity')
    public static List<Reponse> execute(List<Request> requestLst){	
        List<Reponse> responseList = new List<Reponse>();
        
        for(Request req : requestLst){ 
            Map<String, Object> recordMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(req.record));
            
            if(!String.isBlank(req.opportunityId)){
                recordMap.put(req.fieldApiName,req.opportunityId);
            }

			SObject record = (SObject) JSON.deserialize(
                JSON.serialize(recordMap), 
                SObject.class
            );
            
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                        AccessType.UPSERTABLE,  new List<SObject>{record});

            if(!(securityDecision.getRecords()).isEmpty()){
                upsert securityDecision.getRecords();

                List<SObject> obj = (List<SObject>) securityDecision.getRecords();
                Reponse resp = new Reponse();
                resp.recordId = obj[0].Id;
                responseList.add(resp);
            }else{
                Reponse resp = new Reponse();
                resp.recordId = null;
                responseList.add(resp);
            }
        }
        
        return responseList;
    }
    
    /**
     * @description This is request wrapper
     */
    public class Request{
        
        @InvocableVariable(label = 'Record' description = 'Record' required = true)
        public SObject record;
        
        @InvocableVariable(label = 'Field Api Name' description = 'Field Api Name' required = true)
        public String fieldApiName;
        
        @InvocableVariable(label = 'Opportunity Id' description = 'Record Id of Opportunity' required = true)
        public String opportunityId;
    }
    
    /**
     * @description This is response wrapper
     */
    public class Reponse{
        
        @InvocableVariable(label = 'Record Id' description = 'Id of Created Record' required = true)
        public String recordId;
    }
}