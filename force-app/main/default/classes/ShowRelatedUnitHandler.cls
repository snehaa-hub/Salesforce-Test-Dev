/**
 * @description This class is used in ShowRelatedUnit LWC Component
 */
public without sharing class ShowRelatedUnitHandler {

    /**
     * @description This method is used to show all the units that exists in unit bumdle
     * @param unitBundleId
     * @param baseURL
     * @return data in json format
     */
    @Auraenabled(cacheable=true)
    public static String getUnits(String unitBundleId, String baseURL) {
        // Strip fields that are not readable
        SObjectAccessDecision decision = Security.stripInaccessible(
                                            AccessType.READABLE,
                                            [SELECT Id, Linked_Unit__c
                                                FROM Unit_Bundle__c 
                                                WHERE Id =: unitBundleId]);

        if(!(decision.getRecords()).isEmpty()) {
            List<Unit_Bundle__c> unitBundelList = (List<Unit_Bundle__c>) decision.getRecords();
            Unit_Bundle__c unitBundle = unitBundelList[0];
            
            List<Map<String,Object>> unitMapList = new List<Map<String,Object>>();
            if(!String.isBlank(unitBundle.Linked_Unit__c)){
                List<String> shortListedUnits = (List<String>) JSON.deserialize(unitBundle.Linked_Unit__c,List<String>.class);

                SObjectAccessDecision decisionShortlistedUnit = Security.stripInaccessible(
                                            AccessType.READABLE,
                                            [SELECT Id, Unit__c, Unit__r.Tower_Block__c,
                                                Unit__r.Name, Unit_Status__c,
                                                Unit__r.Tower_Block__r.Name, Unit__r.Floor__c,
                                                Unit__r.Type_of_Unit__c, Unit__r.Unit_Category__c
                                                FROM Shortlisted_Unit__c
                                                WHERE Id In: shortListedUnits
                                                ORDER BY Unit__r.Unit_Category__c, Unit__r.Name ASC
                                            ]);

                if(!(decisionShortlistedUnit.getRecords()).isEmpty()) {
                    for(Shortlisted_Unit__c shortListedUnit: (List<Shortlisted_Unit__c>) decisionShortlistedUnit.getRecords()){
                        Map<String,Object> unitMap = new Map<String,Object>();
                        String url = baseURL +'/lightning/r/Unit__c/'+shortListedUnit.Unit__c+'/view';
                        unitMap.put('URL',url);
                        unitMap.put('Id',shortListedUnit.Unit__c);
                        unitMap.put('Name',shortListedUnit.Unit__r.Name);
                        unitMap.put('TowerName',shortListedUnit.Unit__r.Tower_Block__r.Name);
                        unitMap.put('Floor',shortListedUnit.Unit__r.Floor__c);
                        unitMap.put('Status',shortListedUnit.Unit_Status__c);
                        unitMap.put('Type_Of_Unit',shortListedUnit.Unit__r.Type_of_Unit__c);
                        unitMap.put('Unit_Category',shortListedUnit.Unit__r.Unit_Category__c);
                        unitMapList.add(unitMap);
                    }
                }
            }
            return JSON.serialize(unitMapList);
        }
        return null;
    }
}