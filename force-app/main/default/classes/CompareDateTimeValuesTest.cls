@isTest
public class CompareDateTimeValuesTest {
    @isTest
    public static void testhasDateChanged(){
        CompareDateTimeValues.DateTimeComparisonInput input = new CompareDateTimeValues.DateTimeComparisonInput();
        
        input.oldValue = Datetime.now();
        input.newValue = input.oldValue.addHours(1);

        input.oldReminderValue = Datetime.now().addMinutes(30);
        input.newReminderValue = input.oldReminderValue;
        
        
        List<CompareDateTimeValues.DateTimeComparisonInput> inputs = new List<CompareDateTimeValues.DateTimeComparisonInput>();
        inputs.add(input);
        
       
        List<Boolean> results = CompareDateTimeValues.hasDateChanged(inputs);
        
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0], 'Expected true since datetime changed');
    }
}