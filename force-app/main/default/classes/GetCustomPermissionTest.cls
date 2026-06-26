@isTest
public class GetCustomPermissionTest {

    @isTest
    static void testGetCustomPermission() {
        // Create a test Request
        GetCustomPermission.Requests testRequest = new GetCustomPermission.Requests();
        testRequest.permissionName = 'TestPermission';

        // Execute the GetCustomPermission method
        List<Boolean> result = GetCustomPermission.execute(new List<GetCustomPermission.Requests> { testRequest });

        // Assert that the method returns a non-null value
        System.assertNotEquals(null, result,'mesg');

        // Assert that the user has the TestPermission
        System.assertEquals(false, result[0],'mesg');
        GetCustomPermission.hasPermission(testRequest.permissionName);
    }
}