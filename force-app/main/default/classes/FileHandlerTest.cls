/*@isTest
public class FileHandlerTest {
    @isTest
    static void testGetUserProfile() {
        
        Profile platformProfile = [SELECT Id FROM Profile WHERE Name = 'Platform Profile' LIMIT 1];

      
        User testUser = new User(
            FirstName = 'All Warehouses',
            LastName = 'Chennai',
            Email = 'platformuser@example.com',
            Username = 'platformuser123@example.com',
            Alias = 'achen',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = platformProfile.Id
        );
        insert testUser;

        
        System.runAs(testUser) {
            Test.startTest();
            String profileName = FileHandler.getUserProfile();
             Test.stopTest();
            

          
            System.assertEquals('Platform Profile', profileName, 'Profile name should be Platform Profile');
            System.debug('Fetched Profile: ' + profileName);
           
        }
    }
}*/
@isTest
private class FileHandlerTest {

    // Helper method to create test user
    private static User createTestUser() {

        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ];

        String uniqueUsername =
            'testuser' + System.currentTimeMillis() + '@test.com';

        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = uniqueUsername,
            Username = uniqueUsername,
            Alias = 'tuser',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id
        );

        insert u;
        return u;
    }

    @isTest
    static void testGetUserProfile() {

        User testUser = createTestUser();

        System.runAs(testUser) {

            Test.startTest();

            Map<String, String> result =
                FileHandler.getUserProfile();

            Test.stopTest();

            System.assertNotEquals(
                null,
                result,
                'Result should not be null'
            );

            System.assertEquals(
                testUser.Username,
                result.get('userName'),
                'Username should match'
            );

            System.assertEquals(
                'System Administrator',
                result.get('profileName'),
                'Profile name should match'
            );
        }
    }
}