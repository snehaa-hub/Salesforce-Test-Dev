/**
* @description This class to used get opportunity details by passing (Project Id, Account Id and Opportunity stage)
*/
public  without Sharing class ConvertAndGetOpportunityByFilters {
    // For Single Execution
    /**
* @description This invocable method to used get opportunity details by passing (Project Id, Account Id and Opportunity stage)
* @param requestLst
* @return list of response
*/
    @InvocableMethod(label='Convert And Get Opportunity By Filter' description='Convert And Get Opportunity By Filter')
    public static List<Response> execute(List<Request> requestLst){
        Integer index = 0;
        
        List<Response> respList = new List<Response>();
        List<QueryBuilder.Condition> conditionList = new List<QueryBuilder.Condition>();
        String recordJSON;
        
        if(!String.isBlank(requestLst[index].projectId)){
            String projectField = Opportunity_Field_Map__mdt.getInstance('ProjectId_field_Map').Field_Api_Name__c;
            String accountField = Opportunity_Field_Map__mdt.getInstance('AccountId_Field_Map').Field_Api_Name__c;
            String stageField = Opportunity_Field_Map__mdt.getInstance('Stage_Field_Mapping').Field_Api_Name__c;
            
            conditionList.add(new QueryBuilder.CompareCondition(projectField).eq(requestLst[index].projectId));
            conditionList.add(new QueryBuilder.CompareCondition(accountField).eq(requestLst[index].accountId));
            conditionList.add(new QueryBuilder.InCondition(stageField).inCollection(requestLst[index].stageList));
            
            recordJSON = OpportunityConversionHelper.getOpportunity(conditionList,'1 AND 2 AND 3');
        }else{
            String accountField = Opportunity_Field_Map__mdt.getInstance('AccountId_Field_Map').Field_Api_Name__c;
            String stageField = Opportunity_Field_Map__mdt.getInstance('Stage_Field_Mapping').Field_Api_Name__c;
            
            conditionList.add(new QueryBuilder.CompareCondition(accountField).eq(requestLst[index].accountId));
            conditionList.add(new QueryBuilder.InCondition(stageField).inCollection(requestLst[index].stageList));
            
            recordJSON = OpportunityConversionHelper.getOpportunity(conditionList,'1 AND 2');
        }
        
        List<OpportunityWrapper> oppWrapList = new List<OpportunityWrapper>();
        oppWrapList.addall(OpportunityConversionHelper.convertOpportunityToWrapper(recordJSON));
        
        Response resp = new Response();
        resp.opportunityWrap = oppWrapList;
        resp.noOfRecords = oppWrapList.size();
        respList.add(resp);
        
        return respList;
    }
    
    /**
* @description This is request wrapper
*/
    public class Request{
        @InvocableVariable(label = 'Project Id' description = 'Project Id' required = false)
        public String projectId;
        
        @InvocableVariable(label = 'Account Id' description = 'Account Id' required = true)
        public String accountId;
        
        @InvocableVariable(label = 'Stage Name List' description = 'Stage Name  List' required = true)
        public List<String> stageList;
    }
    
    /**
* @description This is response wrapper
*/
    public class Response{
        @InvocableVariable(label = 'Opportunity' description = 'Opportunity Record' required = true)
        public List<OpportunityWrapper> opportunityWrap;
        
        @InvocableVariable(label = 'No Of Records' description = 'No Of Records' required = true)
        public Integer noOfRecords;
    }
}