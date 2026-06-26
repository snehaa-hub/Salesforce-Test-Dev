@isTest public class CreateBooking_test {
    
    @isTest static void CreateBookingTestMethod(){
        
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
            
            Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.Person_Account_RecordType_Name).getRecordTypeId();
            
            Account acc = new Account();
            acc.RecordTypeID = personAccountId;
            acc.FirstName = 'Test';
            acc.LastName = 'User';
            acc.PersonEmail = 'TestUser@gmail.com';
            acc.PersonMobilePhone = '65464453435';
            insert acc;
            Project__c project = new Project__c();
            project.Name = 'Test Project';
            insert project;
            Opportunity opp = new Opportunity();
            opp.Name='test';
            opp.AccountId=acc.id;
            opp.CloseDate=system.today();
            opp.StageName='Prospecting';
            insert opp;
            
            Unit__c unit = new Unit__c ();
            //unit.Name = 'Unit 1';
            unit.Type_of_Unit__c = 'Land';
            unit.City__c = 'City1';
            unit.Country__c = 'Country1';
            unit.Postal_Code__c = '12345';
            unit.Saleable_Area__c = 1500;
            unit.State__c = 'State1';
            unit.Street__c = 'Street1';
            unit.Unit_Status__c = 'Available';
            unit.Unit_Location__Latitude__s = 30.7333;
            unit.Unit_Location__Longitude__s = 76.7794;
            unit.Budget__c = '2.5 lakh to 5 lakh';
            unit.Point_of_Contact__c = acc.Id;
            unit.Size_Range__c = 'below 10000';
            insert unit;
            
            List<Shortlisted_Unit__c> ShortlistedUnitList = new List<Shortlisted_Unit__c>(); 
            Shortlisted_Unit__c shortList = new Shortlisted_Unit__c();
            shortList.Status__c='Shortlisted';
           // shortList.Opportunity__c=opp.id;
            shortList.Unit__c = Unit.id;
            ShortlistedUnitList.add(shortList);
            try{
                insert shortList;  
            }catch(exception ex){
                
            }
            
            
            List<string> ShortlistedUnitList1 = new List<string>(); 
            ShortlistedUnitList1.add(ShortlistedUnitList[0].id);
            Booking__c booking = new Booking__c();
            booking.name='testbooking';
            
            booking.Booking_Date__c=system.today();
            insert booking;
            List<Booking_Line_Item__c> bookingLineItemList = new List<Booking_Line_Item__c>(); 
            Booking_Line_Item__c bookingLineItem = new Booking_Line_Item__c();
            bookingLineItem.name = 'testing';
            bookingLineItem.Quantity__c=12;
            bookingLineItem.Booking__c=booking.id;
            bookingLineItem.Unit__c=unit.id;
            
            bookingLineItemList.add(bookingLineItem);
            
            
            
            List<CreateBooking.Request> reqlist= new List<CreateBooking.Request>();
            CreateBooking.Request req= new CreateBooking.Request();
            req.bookingId = booking.id;
            req.shorListUnits= JSON.serialize(ShortlistedUnitList1);
            
            reqlist.add(req);
            Test.startTest();
            CreateBooking.execute(reqlist);
            
            Test.stopTest();
        }
    }
    
    
}