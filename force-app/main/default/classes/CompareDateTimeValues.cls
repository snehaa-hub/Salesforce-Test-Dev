public class CompareDateTimeValues {
    //Flow name : Drag and drop
	@InvocableMethod(label='Compare DateTime Values' description='Returns true if DateTime value has changed')
    public static List<Boolean> hasDateChanged(List<DateTimeComparisonInput> inputs) {
        List<Boolean> results = new List<Boolean>();
        for (DateTimeComparisonInput input : inputs) {
            Boolean isChanged = false;
            if ((input.oldValue != input.newValue) || (input.oldReminderValue != input.newReminderValue)) {
                isChanged = true;
            }
            results.add(isChanged);
        }
        return results;
    }

    public class DateTimeComparisonInput {
        @InvocableVariable(label='Old StartDateTime Value')
        public Datetime oldValue;

        @InvocableVariable(label='New StartDateTime Value')
        public Datetime newValue;
        
        @InvocableVariable(label='Old ReminderDateTime Value')
        public Datetime oldReminderValue;

        @InvocableVariable(label='New ReminderDateTime Value')
        public Datetime newReminderValue;
    }
}