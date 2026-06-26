/**
 * @description This class to used get opportunity details by passing recordId
 */
public class ConvertAndGetOpportunityById {

    /**
     * @description This invocable method to used get opportunity details by passing recordId
     * @param requestLst
     * @return list of response
     */
	@InvocableMethod(label='Convert And Get Opportunity By Id' description='Convert And Get Opportunity By Id')
    public static List<Response> execute(List<Request> requestLst){
        Integer index = 0;
        System.debug('14 requestLst from ConvertAndGetOpportunityById:'+requestLst);
        List<Response> respList = new List<Response>();
        List<QueryBuilder.Condition> conditionList = new List<QueryBuilder.Condition>();

        conditionList.add(new QueryBuilder.CompareCondition('Id').eq(requestLst[index].opportunityId));
        
        String recordJSON = OpportunityConversionHelper.getOpportunity(conditionList,'1');
		System.debug('Record Json :'+recordJSON);
        List<OpportunityWrapper> oppWrapList = new List<OpportunityWrapper>();
        oppWrapList.addall(OpportunityConversionHelper.convertOpportunityToWrapper(recordJSON));
        System.debug('oppWrapList :'+oppWrapList);
        Response resp = new Response();
        resp.opportunityWrap = oppWrapList;
       respList.add(resp);
        
        return respList;
    }
    
    /**
     * @description This is request wrapper
     */
    public class Request{
        @InvocableVariable(label = 'Opportunity Id' description = 'Opportunity Id' required = true)
        public String opportunityId;
    }
    
    /**
     * @description This is response wrapper
     */
    public class Response{
        @InvocableVariable(label = 'Opportunity' description = 'Opportunity' required = true)
        public List<OpportunityWrapper> opportunityWrap;
    }
}