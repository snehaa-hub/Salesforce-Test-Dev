/**
* @File Name : TaskNotificationHandler.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 2, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 2, 2025 |   | Initial Version
**/

	public class TaskNotificationHandler {
	@AuraEnabled
	public static void LightningStudio(){
		System.debug('Lightning Studio');
	}
}