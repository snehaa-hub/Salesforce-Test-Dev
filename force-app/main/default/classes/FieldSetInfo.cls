/**
 * @description This class that is used to get fields defined in particular fields set.
 */
global with sharing class FieldSetInfo {

    /**
     * @description This method is used to get fields defined in particular fields set.
     * @param recordId
     * @param objectName
     * @param fieldSetName
     * @return Wrapper having details about fields in particualr fieldset
     */
    @AuraEnabled(cacheable=true)
    global static FieldSet getFieldSet(String recordId, String objectName, String fieldSetName) {
        FieldSet form = new FieldSet();
        form.Fields = getFields(recordId, objectName, fieldSetName);

        return form;
    }

    /**
     * @description This is helper method used to get fields defined in particular fields set.
     * @param recordId
     * @param objectName
     * @param fieldSetName
     * @return List of fields(Wrapper)
     */
    private static List<Fields> getFields(String recordId, String objectName, String fieldSetName) {
        Schema.SObjectType objectType = null;

        if (!String.isBlank(recordId)) {
            objectType = (Id.valueOf(recordId)).getSobjectType();
        } else if (String.isNotBlank(objectName)) {
            objectType = Schema.getGlobalDescribe().get(objectName);
        }

        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();

        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();

        List<Fields> fields = new List<Fields>();

        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            Fields fieldWrap = new Fields(fsm);
            fields.add(fieldWrap);
        }

        return fields;
    }

    


    /**
     * @description Wrapper class
     */
    global class FieldSet {
        @AuraEnabled
        global List<Fields> Fields { get; set; }

        /**
         * @description Constructor
         */
        global FieldSet() {
            Fields = new List<Fields>();
        }
    }

    /**
     * @description Wrapper class
     */
    global class Fields {
        /**
         * @description Constructor
         * @param fsm
         */
        global Fields(Schema.FieldSetMember fsm) {
            this.isRequired = fsm.DBRequired;
            this.apiName = fsm.fieldPath;
            this.label = fsm.label;
            this.required = fsm.required;
            this.type = String.valueOf(fsm.getType());
        }

        /**
         * @description Constructor
         * @param required
         */
        global Fields(Boolean required) {
            this.isRequired = required;
        }

        /**
         * @description Stores if field is required
         */
        @AuraEnabled
        global Boolean isRequired { get; set; }

        /**
         * @description Stores api name of field
         */
        @AuraEnabled
        global String apiName { get; set; }

        /**
         * @description Stores label of field
         */
        @AuraEnabled
        global String label { get; set; }

        /**
         * @description if field is required
         */
        @AuraEnabled
        global Boolean required { get; set; }

        /**
         * @description Stores data-type of field
         */
        @AuraEnabled
        global String type { get; set; }
    }




    

}