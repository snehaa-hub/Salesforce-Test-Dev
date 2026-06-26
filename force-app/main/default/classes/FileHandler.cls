/**
* @File Name : FileHandler.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : April 25, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 25, 2025 |   | Initial Version
**/
/*public class FileHandler {
    @AuraEnabled(cacheable=true)
    public static String getUserProfile() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }
}*/
public class FileHandler {
 @AuraEnabled(cacheable=true)
public static Map<String, String> getUserProfile() {
    User currentUser = [SELECT Username, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
    return new Map<String, String>{
        'profileName' => currentUser.Profile.Name,
        'userName'    => currentUser.Username  // e.g. pooja@company.com
    };
}
 @AuraEnabled
    public static void deleteFile(String contentDocumentId) {
        try {
            ContentDocument cd = [SELECT Id FROM ContentDocument 
                                  WHERE Id = :contentDocumentId LIMIT 1];
            delete cd;
        } catch (Exception e) {
            throw new AuraHandledException('Delete failed: ' + e.getMessage() + ' | Type: ' + e.getTypeName());
        }
    }
}