@isTest
public class EmployeeTimeSheetsTriggerHandlerTest {
	@isTest
    static void testCalculateTotalWorkingHours_AllCases() {
        Employee_Time_Sheet__c validRecord = new Employee_Time_Sheet__c(
            Time_In__c = Time.newInstance(10, 0, 0, 0),
            Time_Out__c = Time.newInstance(18, 30, 0, 0)
        );
        Employee_Time_Sheet__c missingTimeIn = new Employee_Time_Sheet__c(
            Time_In__c = null,
            Time_Out__c = Time.newInstance(12, 0, 0, 0)
        );
        Employee_Time_Sheet__c exceptionRecord = new Employee_Time_Sheet__c(
            Time_In__c = Time.newInstance(1, 0, 0, 0),
            Time_Out__c = Time.newInstance(2, 0, 0, 0)
        );
        Test.startTest();
        EmployeeTimeSheetsTriggerHandler.calculateTotalWorkingHours(
            new List<Employee_Time_Sheet__c>{validRecord, missingTimeIn, exceptionRecord}
        );
        Test.stopTest();
        System.assertEquals('8 Hrs 30 Min', validRecord.Total_Working_Hours__c);
        System.assertEquals(8.5, validRecord.Total_Working_Hours1__c);

        System.assertEquals(null, missingTimeIn.Total_Working_Hours__c);
        System.assertEquals(null, missingTimeIn.Total_Working_Hours1__c);

        /*System.assertEquals(null, exceptionRecord.Total_Working_Hours__c);
        System.assertEquals(null, exceptionRecord.Total_Working_Hours1__c);*/
    }  
}