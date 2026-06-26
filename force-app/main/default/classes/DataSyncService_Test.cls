@isTest
private class DataSyncService_Test {
    
    @isTest
    static void testInitialize() {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User u = new User();
        u.FirstName = 'test';
        u.LastName = 'test';
        u.Alias = 'ttest';
        u.Email = 'test@gmail.com';
        u.Username = 'test@gmail.com.stylam202204';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = pf.Id;
        INSERT u;

        system.runAs(u){
            PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = newPermission.Id;
            INSERT psa;
                // Create test data
            String apiRequest = 'Sample API Request';
            String eventType = '99 Acrs	';
            String syncDirection = 'Inbound';
            
            // Create an instance of DataSyncService
            DataSyncService dataSyncService = new DataSyncService();
            
            // Call the initialize method
            Test.startTest();
            dataSyncService.initialize(apiRequest, eventType, syncDirection);
            Test.stopTest();
            
            // Retrieve the created Data_Sync_Log__c record
            Data_Sync_Log__c logRecord = [SELECT Id, API_Request__c, Event_Type__c, Sync_Direction__c, Status__c 
                                        FROM Data_Sync_Log__c LIMIT 1];
            
        }
    }
    
    @isTest
    static void testSuccess() {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User u = new User();
        u.FirstName = 'test';
        u.LastName = 'test';
        u.Alias = 'ttest';
        u.Email = 'test@gmail.com';
        u.Username = 'test@gmail.com.stylam202204';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = pf.Id;
        INSERT u;

        system.runAs(u){
            PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = newPermission.Id;
            INSERT psa;
            // Create test data
            String apiResponse = 'Sample API Response';
            
            // Create an instance of DataSyncService
            DataSyncService dataSyncService = new DataSyncService();
            
            // Call the initialize method first
            dataSyncService.initialize('Sample API Request', '99 Acrs', 'Inbound');
            
            // Call the success method
            Test.startTest();
            try{
                dataSyncService.success(apiResponse);
                // Retrieve the updated Data_Sync_Log__c record
                Data_Sync_Log__c logRecord = [SELECT Id, Status__c, API_Response__c 
                                            FROM Data_Sync_Log__c LIMIT 1];
            }catch(Exception e){
                
            }
        Test.stopTest();
        }
    }
    
    @isTest
    static void testError() {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User u = new User();
        u.FirstName = 'test';
        u.LastName = 'test';
        u.Alias = 'ttest';
        u.Email = 'test@gmail.com';
        u.Username = 'test@gmail.com.stylam202204';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = pf.Id;
        INSERT u;

        system.runAs(u){
            PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.Id;
            psa.PermissionSetId = newPermission.Id;
            INSERT psa;
            // Create test data
            String apiResponse = 'Sample API Response';
            
            // Create an instance of DataSyncService
            DataSyncService dataSyncService = new DataSyncService();
            
            // Call the initialize method first
            dataSyncService.initialize('Sample API Request', '99 Acrs', 'Inbound');
            
            // Call the error method
            Test.startTest();
            try{
                dataSyncService.error(apiResponse);
                
                // Retrieve the updated Data_Sync_Log__c record
                Data_Sync_Log__c logRecord = [SELECT Id, Status__c, API_Response__c 
                                            FROM Data_Sync_Log__c LIMIT 1];
                
            }catch(Exception e){
                
            }
            
            Test.stopTest();
        }
    }
}