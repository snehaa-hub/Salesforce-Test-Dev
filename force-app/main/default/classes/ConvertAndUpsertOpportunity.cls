/**
 * @description This class to used upsert opportunity record dynamically
 */
public without sharing class ConvertAndUpsertOpportunity {
    
    /**
     * @description This invocable method to used upsert opportunity record dynamically
     * @param requestLst
     */
    @InvocableMethod(label='Convert And Upsert Opportunity' description='Convert And Upsert Opportunity')
    public static List<Response> execute(List<Request> requestLst){
        List<Response> responseList = New List<Response>();
        if(!requestLst.isEmpty()){
            List<OpportunityWrapper> opportunityWrapList = new List<OpportunityWrapper>();
            for(Request req: requestLst){
                opportunityWrapList.add(req.opportunityWrap);
            }

            if(!opportunityWrapList.isEmpty()){
				List<SObject> sObjectList = new List<SObject>();
                sObjectList.addall(OpportunityConversionHelper.convertWrapperToOpportunity(opportunityWrapList));
                
                if(!sObjectList.isEmpty()){
                    SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                        AccessType.UPSERTABLE,  sObjectList);

                    if(!(securityDecision.getRecords()).isEmpty()){
                        upsert securityDecision.getRecords();
                        
                        for(Object obj: (List<Object>) securityDecision.getRecords()){
                        // for(Object obj: securityDecision.getRecords()){
                            // SObject sObj = (SObject) obj;
                            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                            Response res = new Response();
                            res.recordId = (String) objMap.get('Id');
                            // res.recordId = (String) sObj.get('Id');
                            responseList.add(res);
                        }
                    }
                }
            }
        }
        
        return responseList;
    }
    
    /**
     * @description This is request wrapper
     */
    public class Request{
        @InvocableVariable(label = 'Opportunity' description = 'Opportunity Data for Update' required = true)
        public OpportunityWrapper opportunityWrap;
    }
    
    /**
     * @description This is response wrapper
     */
    public class Response{
        @InvocableVariable(label = 'Record Id' description = 'Record Id' required = true)
        public String recordId;
    }
}