/**
* @File Name : TaskNotificationHelper.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 3, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 3, 2025 |   | Initial Version
**/

public class TaskNotificationHelper {
    @AuraEnabled
    public static void LightningStudio(){
        System.debug('Lightning Studio');
    }
}