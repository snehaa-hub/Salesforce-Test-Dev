/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : FieldSetController
 * Author          : <ArunKumar raja>
 * Created Date    : Mar 9, 2026
 * Last Modified By: <Arun Kumar Raja>
 * Last Modified On: Mar 9, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Mar 9, 2026  │ <ArunKumar raja>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public with sharing class FieldSetController {
    
    @AuraEnabled(cacheable=true)
    public static List<FieldSetMemberWrapper> getFieldsFromFieldSet(String objectName, String fieldSetName) {
        
        List<FieldSetMemberWrapper> fieldSetFields = new List<FieldSetMemberWrapper>();
        
        if(String.isBlank(objectName) || String.isBlank(fieldSetName)){
            return fieldSetFields;
        }

        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
        if(sObjType == null){
            return fieldSetFields;
        }

        Schema.DescribeSObjectResult describe = sObjType.getDescribe();
        Schema.FieldSet fieldSet = describe.fieldSets.getMap().get(fieldSetName);
        
        if (fieldSet != null) {
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                fieldSetFields.add(new FieldSetMemberWrapper(f));
            }
        }

        return fieldSetFields;
    }

    public class FieldSetMemberWrapper {

        @AuraEnabled public String label;
        @AuraEnabled public String apiName;
        @AuraEnabled public Boolean required;
        @AuraEnabled public String type;

        public FieldSetMemberWrapper(Schema.FieldSetMember f) {
            label = f.getLabel();
            apiName = f.getFieldPath();
            required = f.getRequired() || f.getDBRequired();
            type = String.valueOf(f.getType());
        }
    }
    @AuraEnabled
public static Boolean checkEmailExists(String email){

    List<Enquiry__c> enquiries = [
        SELECT Id
        FROM Enquiry__c
        WHERE Email__c = :email
        LIMIT 1
    ];

    return !enquiries.isEmpty();
}
}