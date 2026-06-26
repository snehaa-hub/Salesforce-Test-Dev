trigger EmployeeTimeSheetsTrigger on Employee_Time_Sheet__c (before insert, before update) {
	if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            EmployeeTimeSheetsTriggerHandler.calculateTotalWorkingHours(Trigger.new);
        }
    }
}