/**
* @description This class is used to get all the unit bundle with respect to opportunity and has unit with a specific OC/CC Status
*/
public without sharing class GetUnitBundle{
    
    /**
* @description This invocable method that is used to get all the unit bundle with respect to opportunity and has unit with a specific OC/CC Status
* @param requestLst
* @return list of response
*/
    @InvocableMethod(label='Get Unit Bundle')
    public static List<Response> execute(List<Requests> requestLst){
        List<Response> responseList = new List<Response>();
        System.debug('14 requestLst' +requestLst);
        if(!requestLst.isEmpty()){
            Map<String,Requests> opportunityMap = new Map<String,Requests>();
            for(Requests req: requestLst){
                if(!String.isBlank(req.opportunityId)){
                    opportunityMap.put(req.opportunityId, req);
                }
            }   
            
            Map<String,Shortlisted_Unit__c> shortListedUnitMap = new Map<String,Shortlisted_Unit__c>();
            
            String numString = String.join(opportunityMap.keySet(), '\',\'');
            
            String shortListedQuery = 'SELECT Id,Name, Unit__c, Unit__r.Id '; 
            shortListedQuery = shortListedQuery + ' FROM Shortlisted_Unit__c';
            if(!opportunityMap.isEmpty()){
                shortListedQuery = shortListedQuery + ' WHERE Opportunity__c IN (\''+ String.escapeSingleQuotes(numString) +'\')';
            }
            List<Shortlisted_Unit__c> selectedUnitsList = database.query(shortListedQuery);
            
            for(Shortlisted_Unit__c shortListedUnit: selectedUnitsList){
                shortListedUnitMap.put(shortListedUnit.Id,shortListedUnit);
            }
            
            Set<String> unitBundleIds = new Set<String>();
            
            String unitBundleQuery;        
            if(!Test.isRunningTest()){
                unitBundleQuery = 'SELECT Id,  Name';        
            }else{
                unitBundleQuery = 'SELECT Id, Name';   
            }
            unitBundleQuery = unitBundleQuery + ', Opportunity__c FROM Unit_Bundle__c';
            if(!opportunityMap.isEmpty()){
                unitBundleQuery = unitBundleQuery + ' WHERE Opportunity__c IN (\''+ String.escapeSingleQuotes(numString) +'\')';
            }
            List<Unit_Bundle__c> unitBundleList = database.query(unitBundleQuery);
            for(Unit_Bundle__c unitBundle: unitBundleList){
                Map<String, Object> unitBundleMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(unitBundle));
                Boolean matchesOcStatus = true;
                
                //String linkedUnits = (String) unitBundleMap.get('Linked_Unit__c');
                String opporunityId;
                
                if(!String.isBlank((String) unitBundleMap.get('Opportunity__c'))){
                    opporunityId = (String) unitBundleMap.get('Opportunity__c');
                }
                
                unitBundleIds.add((String) unitBundleMap.get('Id'));
            }
            //}
            
            List<String> unitBundleIdList = new List<String>();
            if(!unitBundleIds.isEmpty()){
                unitBundleIdList.addAll(unitBundleIds);
            }
            
            Response resp = new Response();
            resp.unitBundleIds = unitBundleIdList; 
            responseList.add(resp);
        }
        return responseList;
    }
    
    /**
* @description This is response wrapper
*/
    public class Response {
        @InvocableVariable(label='Unit Bundle Ids' required=true)
        public List<String> unitBundleIds;
    }
    
    /**
* @description This is request wrapper
*/
    public class Requests {
        
        @InvocableVariable(label='Opportunity Id' required=true)
        public String opportunityId;
        
    }
}