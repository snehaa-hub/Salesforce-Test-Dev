/**
 * @description This class is used to get opportunity value from a record dynamically
 */
public class GetOpportunityValue {
    
    /**
     * @description This invocable mthod is used to get opportunity value from a record dynamically
     * @param requestLst
     * @return list of response
     */
    @InvocableMethod(label='Get Opportunity Value' description='Get Opportunity Value')
    public static List<Response> execute(List<Request> requestLst){ 
        List<Response> responseList = new List<Response>();

        for(Request req : requestLst){ 
            Map<String, Object> recordMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(req.record));
            
            Response res = new Response();
            res.opportunityId = (String) recordMap.get(req.fieldApiName);
            responseList.add(res);
        }

        return responseList;
    }

    /**
     * @description This is request wrapper
     */
    public class Request{

        @InvocableVariable(label = 'Record' description = 'Record from which need to get value' required = true)
        public SObject record;
        
        @InvocableVariable(label = 'Field Api Name' description = 'Field Api Name of Opportunity' required = true)
        public String fieldApiName;
    }

    /**
     * @description This is response wrapper
     */
    public class Response{

        @InvocableVariable(label = 'Opportunity Id' description = 'Record Id of Opportunity')
        public String opportunityId;
    }
}