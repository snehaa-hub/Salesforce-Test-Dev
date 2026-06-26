public class RemoveUnitFromUnitBundle {
    @InvocableMethod(label='Remove Unit From Unit Bundle' description='Remove Unit From Unit Bundle')
    public static List<Response> execute(list<Request> reqs){
        List<Unit_Bundle__c> unitBundles = new List<Unit_Bundle__c>();
        List<Response> responseList = new List<Response>();
        
        for(Request req: reqs){
            Set<String> shortlistedUnits = new Set<String>();

            List<Object> relatedUnits = (List<Object>) JSON.deserializeuntyped(req.unitBundleObj.Linked_Unit__c);
            
            for(Object obj: relatedUnits){
                if((String) obj != req.shortUnitID){
                    shortlistedUnits.add((String) obj);
                }
            }
            
            Boolean errorOccurred = false;
            if(!shortlistedUnits.isEmpty()){
                List<Shortlisted_Unit__c> shortListedUnitList = [SELECT Id
                                                             	FROM Shortlisted_Unit__c
                                                              	WHERE ID In: shortlistedUnits
                                                              	AND Unit__r.Unit_Category__c !=: System.Label.Unit_Category_Parking
                                                             ];
                
                if(shortListedUnitList.isEmpty()){
                    errorOccurred = true;
                }
            }else{
                errorOccurred = true;
            }
            
            List<String> linkedUnits = new List<String>();
            if(errorOccurred == false){
                for(Object obj: relatedUnits){
                    if((String) obj != req.shortUnitID){
                        linkedUnits.add((String) obj);
                    }
                }
                
                req.unitBundleObj.Linked_Unit__c = JSON.serialize(linkedUnits);
                req.unitBundleObj.Number_Of_Base_Units__c = linkedUnits.size();
                unitBundles.add(req.unitBundleObj);
            }
            
            Response resp = new Response();
            resp.showError = errorOccurred;
            responseList.add(resp);
        }
        
        if(!unitBundles.isEmpty()){
            update unitBundles;
        }
        
        return responseList;
    }
    
    public class Response{
        @invocableVariable(label='Show Error' description='Show Error')
        public Boolean showError;
    }
    
    public class Request{
        @invocableVariable(label='Shortlisted Unit ID' description='Shortlisted Unit ID')
        public String shortUnitID;
        
        @invocableVariable(label='Unit Bundle Object' description='Unit Bundle Object')
        public Unit_Bundle__c unitBundleObj;
    }
}