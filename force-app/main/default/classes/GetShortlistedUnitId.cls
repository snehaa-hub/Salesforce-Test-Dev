/**
 * @description This class is used to get all the shortlist unit ids with respect to opportunity
 */
public without sharing class GetShortlistedUnitId {

    /**
     * @description This invocable method is used to get all the shortlist unit ids with respect to opportunity
     * @param requestLst
     * @return list of response(shortlisted ids)
     */
    @InvocableMethod(label='Get Shortlisted Unit Id' description='Get Shortlisted Unit Id')
    public static List<Response> execute(List<Request> requestLst){ 
        List<Response> responseList = new List<Response>();
        
        for(Request req : requestLst){ 
            String shortListedQuery = 'SELECT Id, Name FROM Shortlisted_Unit__c ';      
            if(!String.isBlank(req.opportunityId)){
                shortListedQuery = shortListedQuery + 'WHERE Opportunity__c = \''+ String.escapeSingleQuotes(req.opportunityId) +'\' AND Unit__c = \''+ String.escapeSingleQuotes(req.unitId) +'\'';
            }else{
                shortListedQuery = shortListedQuery + 'WHERE Unit__c = \'' + String.escapeSingleQuotes(req.unitId) +'\'';
            }
            List<Shortlisted_Unit__c> selectedUnitsList = database.query(shortListedQuery);
            System.debug('selectedUnitsList :'+ selectedUnitsList);
            Response res = new Response();
            if(!selectedUnitsList.isEmpty()){
                res.shortlistedUnitId = selectedUnitsList[0].Id;
            }else{
                res.shortlistedUnitId = null;
            }
            responseList.add(res);
        }
        System.debug('32 responseList :'+responseList);
        return responseList;
    }
    
    /**
     * @description This is request wrapper
     */
    public class Request{
        
        @InvocableVariable(label = 'Unit Id' description = 'Unit Id' required = true)
        public String unitId;
        
        @InvocableVariable(label = 'Opportunity Id' description = 'Opportunity Id' required = true)
        public String opportunityId;
    }
    
    /**
     * @description This is response wrapper
     */
    public class Response{
        
        @InvocableVariable(label = 'Shortlisted Unit Id' description = 'Record Id of Shortlisted Unit')
        public String shortlistedUnitId;
    }
}