/**
* @File Name : TaskWrapper.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 29, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 29, 2025 |   | Initial Version
**/

public class TaskWrapper {
	@AuraEnabled public String Subject;
    @AuraEnabled public String OwnerId;
    @AuraEnabled public String assignedByUserId;
    @AuraEnabled public Date ActivityDate;
    @AuraEnabled public String Status;
    @AuraEnabled public String Priority;
    @AuraEnabled public Boolean IsReminderSet;
    @AuraEnabled public String ReminderDateTime;
    @AuraEnabled public String dueDateTime;
	
}