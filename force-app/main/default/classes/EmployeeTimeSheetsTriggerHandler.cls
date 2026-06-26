public class EmployeeTimeSheetsTriggerHandler {
    public static void calculateTotalWorkingHours(List<Employee_Time_Sheet__c> etsList){
        for (Employee_Time_Sheet__c record : etsList) {
            if (record.Time_In__c != null && record.Time_Out__c != null) {
                try {
                    // Convert Time In to total seconds
                    Integer inSeconds = (record.Time_In__c.hour() * 3600) +
                                        (record.Time_In__c.minute() * 60) +
                                        record.Time_In__c.second();

                    // Convert Time Out to total seconds
                    Integer outSeconds = (record.Time_Out__c.hour() * 3600) +
                                         (record.Time_Out__c.minute() * 60) +
                                         record.Time_Out__c.second();

                    Integer durationSeconds = outSeconds - inSeconds;
                    System.debug('durationSeconds'+durationSeconds);

                    // Handle crossing midnight (e.g., 10PM to 2AM next day)
                    if (durationSeconds < 0) {
                        durationSeconds += 24 * 3600; // Add 24 hours in seconds
                    }
                     Integer hours = durationSeconds / 3600;
                    Integer minutes = Math.mod(durationSeconds, 3600) / 60;
					 String formattedTime = hours + ' Hrs ' + minutes + ' Min';
                    Decimal totalHours = durationSeconds / 3600.0;
                    Decimal roundedHours = totalHours.setScale(2);
                     System.debug('roundedHours'+roundedHours);
                    
                   // record.Total_Working_Hours__c = String.valueOf(roundedHours) + ' Hrs';
                    record.Total_Working_Hours__c = formattedTime;
                    record.Total_Working_Hours1__c = roundedHours;
                } catch (Exception e) {
                    System.debug('Error calculating working hours: ' + e.getMessage());
                    record.Total_Working_Hours__c = null;
                    record.Total_Working_Hours1__c = null;
                }
            } else {
                record.Total_Working_Hours__c = null;
                record.Total_Working_Hours1__c = null;
            }
        }
    }
}