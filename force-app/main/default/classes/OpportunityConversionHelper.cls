/**
 * @description This is helper class for operations on opportunity dynamically
 */
public class OpportunityConversionHelper {

    /**
     * @description This method get all fields on opportunity defined in Opportunity Field Map Metadata
     * @return list of string
     */
    public static List<String> getFieldsToQuery(){
        List<String> fieldsToQuery = new List<String>();
        Map<String, Opportunity_Field_Map__mdt> opportunityFieldMappingMap = Opportunity_Field_Map__mdt.getAll();
        if(!opportunityFieldMappingMap.isEmpty()){
            Set<String> fieldsSet = new Set<String>();
            for (String nameleadMapping : opportunityFieldMappingMap.keySet()) {
                String fieldApiName = opportunityFieldMappingMap.get(nameleadMapping).Field_Api_Name__c;
                fieldsSet.add(fieldApiName);
            }
            fieldsToQuery.addall(fieldsSet);
        }
        
        return fieldsToQuery;
    }
    
    /**
     * @description This method converts opportunithy record into opportunity wrapper
     * @param recordJSON
     * @return list of OpportunityWrapper
     */
    public static List<OpportunityWrapper> convertOpportunityToWrapper(String recordJSON){
        List<Object> records = (List<Object>) JSON.deserializeUntyped(recordJSON);
        List<Map<String,Object>> opportunityWrapMapList = new List<Map<String,Object>>();
        Map<String, Opportunity_Field_Map__mdt> opportunityFieldMappingMap = Opportunity_Field_Map__mdt.getAll();
        
        if(!records.isEmpty()){
            for(Object obj: records){
                Map<String,Object> opportunityWrapMap = new Map<String,Object>();
                Map<String, Object> opportunityMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                for (String nameleadMapping : opportunityFieldMappingMap.keySet()) {
                    String variableName = opportunityFieldMappingMap.get(nameleadMapping).Variable_Name__c;
                    String fieldApiName = opportunityFieldMappingMap.get(nameleadMapping).Field_Api_Name__c;
                    opportunityWrapMap.put(variableName,opportunityMap.get(fieldApiName));
                }
                opportunityWrapMapList.add(opportunityWrapMap);
            }
        }
        List<OpportunityWrapper> oppWrapList = (List<OpportunityWrapper>)JSON.deserializeStrict(JSON.serialize(opportunityWrapMapList),List<OpportunityWrapper>.class);
        return oppWrapList;
    }
    
    /**
     * @description This method converts opportunity wrapper into opportunithy record
     * @param opportunityWrapList
     * @return list of Opportunity
     */
    public static List<SObject> convertWrapperToOpportunity(List<OpportunityWrapper> opportunityWrapList){
        Map<String, Opportunity_Field_Map__mdt> opportunityFieldMappingMap = Opportunity_Field_Map__mdt.getAll();
        system.debug('opportunityFieldMappingMap : '+opportunityFieldMappingMap);
        String opportunityApiName = BuildeOpedia_Configuration__mdt.getInstance('OpportunityObjectApiName').value__c;
        List<SObject> sObjectList = new List<SObject>();
        for(OpportunityWrapper opportunityWrap: opportunityWrapList){
            Map<String, Object> opportunityMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(opportunityWrap));
            
            Sobject recordToUpdate = Schema.getGlobalDescribe().get(opportunityApiName).newSObject() ;
            
            for (String nameleadMapping : opportunityFieldMappingMap.keySet()) {
                String variableName = opportunityFieldMappingMap.get(nameleadMapping).Variable_Name__c;
                String fieldApiName = opportunityFieldMappingMap.get(nameleadMapping).Field_Api_Name__c;
                 system.debug('fieldApiName : '+fieldApiName);
                 system.debug('variableName : '+variableName);
                Schema.DisplayType enquiryField = Schema.getGlobalDescribe()
                    .get(opportunityApiName)
                    .getDescribe()
                    .fields
                    .getMap()
                    .get(fieldApiName)
                    .getDescribe()
                    .getType();
                
                if(opportunityMap.get(variableName) != null){  
                    if (string.valueof(enquiryField) == 'DATETIME') {
                        String dateTimeValue = String.valueOf(opportunityMap.get(variableName));
                        dateTimeValue = dateTimeValue.replaceFirst('T', ' ');
                        recordToUpdate.put(fieldApiName, Datetime.valueof(dateTimeValue));
                    } else if (string.valueof(enquiryField) == 'DATE') {
                        String dateValue = String.valueOf(opportunityMap.get(variableName));
                        recordToUpdate.put(fieldApiName, Date.valueof(dateValue));
                    } else {
                        recordToUpdate.put(fieldApiName, opportunityMap.get(variableName));
                        system.debug('fieldApiName 2: '+fieldApiName);
                        system.debug('variableName 2: '+variableName);
                        system.debug('opportunityMap.get(variableName) : '+opportunityMap.get(variableName));
                    }
                }
            }
            sObjectList.add(recordToUpdate);
        }
        
        return sObjectList;
    }
    
    /**
     * @description This method is used to get opportunity data using query builder
     * @param conditionList
     * @param conditionOrder
     * @return Opportunity in Json format
     */
    public static String getOpportunity(List<QueryBuilder.Condition> conditionList, String conditionOrder){
        List<String> fieldsToQuery = new List<String>();
        fieldsToQuery.addall(OpportunityConversionHelper.getFieldsToQuery());
        
        String objectName = BuildeOpedia_Configuration__mdt.getInstance('OpportunityObjectApiName').value__c;
        
        QueryBuilder qB = new QueryBuilder(objectName);
        qB.addFields(String.join(fieldsToQuery, ','));
        
        for(QueryBuilder.Condition condition: conditionList){
            qB.addConditions()
                .add(
                    condition
                );
        }
        
        qB.addConditions()
            .setConditionOrder(conditionOrder);
        qB.addConditions().endConditions();
        
        return JSON.serialize(qB.toList());
    }
}