/**
 * @description This class is used to check if a user has permission to a certain custom permission
 */
global with sharing class GetCustomPermission {
    
    /**
     * @description This is method is used in lwc to check if a user has permission to a certain custom permission 
     * @param permissionName
     * @return Boolean
     */
    @Auraenabled(cacheable=true)
    global static Boolean hasPermission(String permissionName) {
        Boolean havingPermission = FeatureManagement.checkPermission(permissionName);
        return havingPermission;
    }
    
    /**
     * @description This is method is check in flow if a user has permission to a certain custom permission 
     * @param requestLst
     * @return Boolean
     */
    @InvocableMethod(label='Get Custom Permission')
    global static List<Boolean> execute(List<Requests> requestLst) {
        List<Boolean> resultList = new List<Boolean>();

        if (!requestLst.isEmpty()) {
            for (Requests req : requestLst) {
                resultList.add(FeatureManagement.checkPermission(req.permissionName));
            }
        }
        return resultList;
    }

    /**
     * @description Wrapper class to input values from flow
     */
    global class Requests {
        @InvocableVariable(label='Permission Name' required=true)
        global String permissionName;
    }
}