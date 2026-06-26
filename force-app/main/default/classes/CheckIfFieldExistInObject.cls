/**
 * @description This class is used to check if a field exist in an object
 */
global class CheckIfFieldExistInObject {

    /**
     * @description This method is used to check if a field exist in an object
     * @param objName
     * @param fieldName
     * @return true/false
     */
	@AuraEnabled
    global static Boolean checkField(String objName, string fieldName){	
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}