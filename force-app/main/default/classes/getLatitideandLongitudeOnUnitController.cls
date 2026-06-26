public class getLatitideandLongitudeOnUnitController {
    
    @Auraenabled(cacheable=true)
    public static Boolean getUnits(String recordId) {
        // Strip fields that are not readable
        Boolean locationExit = false;
        if(recordId != null && recordId != '')
        {
            
            SObjectAccessDecision decision = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Id, Google_Coordinates_Link__c,Unit_Location__Latitude__s,Unit_Location__Longitude__s
                 FROM Unit__c 
                 WHERE Id =: recordId]);
            if(!(decision.getRecords()).isEmpty()) {
                List<Unit__c> unitList = (List<Unit__c>) decision.getRecords();
                Unit__c unit = unitList[0];
                if((unit.Google_Coordinates_Link__c !='' && unit.Google_Coordinates_Link__c != null)|| unit.Unit_Location__Latitude__s != null)
                {
                    locationExit = true;
                }
            }
        }
        
        return locationExit;
        
        
        
    }
    
}