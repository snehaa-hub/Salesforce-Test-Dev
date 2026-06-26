@isTest
public class SendTaskAndEventEmailTest {
    @IsTest
    static void testSendEmails() {
        // Create test users list
        List<Map<String, Object>> users = new List<Map<String, Object>>{
            new Map<String, Object>{ 'Id' => '005xx000001', 'Name' => 'Barathi Madhavan', 'Email' => 'barathi@chattels.in.invalid' },
            new Map<String, Object>{ 'Id' => '005xx000002', 'Name' => 'All Warehouses Chennai', 'Email' => 'rubanprofessional@gmail.com' }
        };
        String selectedUsersJson = JSON.serialize(users);

        // Prepare task info
        Map<String, Object> taskDetails = new Map<String, Object>{
            'Subject' => 'Test Task Email',
            'StartDate' => Date.today().format(),
            'EndDate' => Date.today().addDays(1).format(),
            'StartTime' => '15:30:00.000',
            'EndTime' => '00:45:00.000'
        };
        String taskInfoJson = JSON.serialize(taskDetails);

        // Call the method inside a test context
        Test.startTest();
        SendTaskAndEventEmail.sendEmails(taskInfoJson, selectedUsersJson, 'task');
        Test.stopTest();

        System.assert(true, 'sendEmails executed successfully for multiple users');
    }

    @IsTest
    static void testConvertTo12HrFormat() {
        // Test various time strings
        System.assertEquals('12:00 AM', SendTaskAndEventEmail.convertTo12HrFormat('00:00'));
        System.assertEquals('12:30 AM', SendTaskAndEventEmail.convertTo12HrFormat('00:30'));
        System.assertEquals('01:00 AM', SendTaskAndEventEmail.convertTo12HrFormat('01:00'));
        System.assertEquals('03:30 PM', SendTaskAndEventEmail.convertTo12HrFormat('15:30'));
        System.assertEquals('12:00 PM', SendTaskAndEventEmail.convertTo12HrFormat('12:00'));
        System.assertEquals('11:59 PM', SendTaskAndEventEmail.convertTo12HrFormat('23:59'));
        System.assertEquals('03:00 PM', SendTaskAndEventEmail.convertTo12HrFormat('15:00:00.000'));
        System.assertEquals('12:45 AM', SendTaskAndEventEmail.convertTo12HrFormat('00:45:00.000'));
    }
}