public class UserController {
        @AuraEnabled(cacheable=true)
        public static List<User> getAllUsers(String searchTerm) {
            if (String.isBlank(searchTerm)) return new List<User>();
        
        String escapedTerm = String.escapeSingleQuotes(searchTerm.trim());
        return [SELECT Id, Name, Email FROM User 
                WHERE Name LIKE :('%' + escapedTerm + '%')
                LIMIT 10];
        }
}