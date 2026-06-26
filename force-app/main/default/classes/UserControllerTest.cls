@isTest
public class UserControllerTest {
	@TestSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Asia/Kolkata',
            ProfileId = p.Id,
            Username = 'testuser' + System.currentTimeMillis() + '@test.com'
        );
        insert testUser;
    }

    @IsTest
    static void testBlankSearchTerm() {
        Test.startTest();
        List<User> result = UserController.getAllUsers('');
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list when searchTerm is blank');
    }

    @IsTest
    static void testValidSearchTerm() {
        User u = [SELECT Id, Name, Email, LastName FROM User WHERE Email LIKE 'testuser%@test.com' LIMIT 1];

        Test.startTest();
        List<User> result = UserController.getAllUsers(u.LastName);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Should return at least one user');
        System.assertEquals(u.Id, result[0].Id, 'Returned user should match the inserted test user');
    }
}