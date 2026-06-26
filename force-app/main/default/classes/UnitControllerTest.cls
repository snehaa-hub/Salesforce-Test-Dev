@isTest
private class UnitControllerTest {
    
    @testSetup
    static void setup() {
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
        
        PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = newPermission.Id;
        INSERT psa;
        system.runAs(u){
            List<Unit__c> units = new List<Unit__c>();
            Unit__c unitData = new Unit__c();
            //unitData.Name = 'Unit 1';
            //unitData.Type_of_Unit__c = 'Factory';
            unitData.City__c = 'City1';
            unitData.Country__c = 'Country1';
            unitData.Postal_Code__c = '12345';
            unitData.Saleable_Area__c = 1500;
            unitData.State__c = 'State1';
            unitData.Street__c = 'Street1';
            unitData.Unit_Status__c = 'Available';
            unitData.Unit_Location__Latitude__s = 30.7333;
            unitData.Unit_Location__Longitude__s = 76.7794;
            unitData.Budget__c = '2.5 lakh to 5 lakh';
            unitData.Size_Range__c = 'below 10000';
            units.add(unitData);
            
            if(!units.isEmpty()){
                insert units;  
            }
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = 'Internal' + '.pdf'; 
            conVer.Title = 'Internal Flat'  + '.pdf';  
            conVer.VersionData = Blob.valueOf('body');
            conVer.FirstPublishLocationId = units[0].Id;
            conVer.SObjectType__c = 'Unit__c';
            conVer.Document_Type__c = 'Internal Images';
            INSERT conVer;
        }
    }
    
    @isTest
    static void testGetFilteredUnits2() {
        Unit__c unit = [SELECT Id, Type_of_Unit__c, City__c, Country__c, Postal_Code__c, Saleable_Area__c, State__c, Unit_Status__c, Unit_Location__Latitude__s, Unit_Location__Longitude__s, Budget__c, Name FROM Unit__c LIMIT 1];
        unit.Budget__c = '2.5 lakh to 5 lakh';
       // unit.Type_of_Unit__c = 'Factory';
        unit.Saleable_Area__c = 0;
        update unit;
        
        Test.startTest();
        
        string city = unit.City__c;
        
        Decimal longitude = 76.7794;
        Decimal latitude = 30.7333;
        
        
        UnitController.searchUnits(city,longitude ,latitude);
        
        Test.stopTest();
        
        
    }
    @isTest
    static void getRelatedCVs_Test(){
        User u = [Select Id from User where UserName = 'test@gmail.com.stylam202204'];
        system.runAs(u){
            Test.StartTest();
            Unit__c unit = [SELECT Id, Type_of_Unit__c, City__c, Country__c, Postal_Code__c, Saleable_Area__c, State__c, Unit_Status__c, Unit_Location__Latitude__s, Unit_Location__Longitude__s, Budget__c, Name FROM Unit__c LIMIT 1];
            ContentVersion cv = [Select Id,Title,SObjectType__c,Document_Type__c,FirstPublishLocationId from ContentVersion where FirstPublishLocationId=:unit.Id limit 1];
            
            UnitController.getRelatedCVs(unit.Id, cv.Document_Type__c);
            Test.stopTest();
        }
    }
    
}