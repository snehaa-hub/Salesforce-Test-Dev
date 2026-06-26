public without sharing class UnitController {
    
    @AuraEnabled
    public static List<Unit__c> searchUnits(String City,Decimal Latitude, Decimal Longitude){
        system.debug('Latitude'+Latitude);
       // Latitude = Latitude.setScale(5);
       // Longitude = Longitude.setScale(5);
       // system.debug('Longitude'+Longitude);
       system.debug('City'+City);
        if(String.isNotBlank(City)){
            List<Unit__c> unitList = [SELECT Name,Unit_Status__c,Type_of_Unit__c,
                                      Unit_Category__c,State__c,
                                      City__c,Street__c,Country__c,
                                      Postal_Code__c,Unit_Location__Longitude__s,
                                      Unit_Location__Latitude__s,Address__c
                                      FROM Unit__c
                                      WHERE City__c LIKE :'%'+City OR
                                      City__c =: City OR
                                      City__c LIKE :City+'%'
                                      /*AND Unit_Location__Latitude__s =: Latitude 
                                      AND Unit_Location__Longitude__s  =: Longitude*/];
           
            if(!unitList.isEmpty()){
                system.debug('unitList'+unitList);
                return unitList;
            }
        }
        
        return null;
        
    }
    
     @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getRelatedCVs(String recordId,String documentType){
        
        if(String.isNotBlank(recordId) && String.isNotBlank(documentType)){
            List<ContentVersion> cvList = [SELECT id
                                          FROM ContentVersion
                                          WHERE FirstPublishLocationId = :recordId];
            if(!cvList.isEmpty()){
                return cvList;
            }
        }
        
        return null;
        
    }

}