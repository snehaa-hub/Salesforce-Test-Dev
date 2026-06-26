@istest 
public class SetBookingName_test {
     @isTest
    static void ReqTestMethod(){
   
        Unit__c unit01 = new Unit__c();
        unit01.Name = 'TestUnit01';
       // unit01.Default_Charge__c = charge.id;
      
        unit01.Carpet_Area__c = 1000;
      //  unit01.Saleable_Area__c = 1000;
       unit01.Unit_UOM__c = 'Feet';
        unit01.Size_Range__c = 'below 10000';
        insert unit01;
        
        Unit__c unit02 = new Unit__c();
        unit02.Name = 'TestUnit02';
     
     
       // unit02.Saleable_Area__c = 1000;
        unit02.Unit_UOM__c = 'Feet';
        unit02.Size_Range__c = 'below 10000';
       // unit02.Preferred_Locations__c = charge01.Id + ';';       
        insert unit02;

   
        
       

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                  .get('Person Account').getRecordTypeId();
        Account personAcct = new account();
        personAcct.lastName = 'ginny';
        personAcct.RecordTypeId = recordTypeId;
        insert personAcct;

        Opportunity__c opp = new Opportunity__c();
        //opp.Account_Name__c = personAcct.id;
        opp.Name = 'TestOpp';
        opp.Close_Date__c = system.today() + 7;
        opp.Stage__c = 'In Progress'; 
        insert opp;

        Shortlisted_Unit__c shortUnit01 = new Shortlisted_Unit__c();
        shortUnit01.Status__c = 'Booked';
        shortUnit01.Unit__c = unit01.id;
        shortUnit01.Opportunity__c = opp.id;
        insert shortUnit01;

        Shortlisted_Unit__c shortUnit02 = new Shortlisted_Unit__c();
        shortUnit02.Status__c = 'Booked';
        shortUnit02.Unit__c = unit02.id;
        shortUnit02.Opportunity__c = opp.id;
        insert shortUnit02;

       
        Unit_Bundle__c unitBundle = new Unit_Bundle__c();
        //unitBundle.Opportunity__c = opp.Id;
        unitBundle.Name = 'TestUnitBundle';
        unitBundle.Linked_Unit__c = '["' + shortUnit01.id + '","' + shortUnit02.id + '"]';
        insert unitBundle;

      

        Booking__c booking = new Booking__c();
        booking.Booking_Date__c = System.today();
        booking.Related_Opportunity__c = opp.Id;
        insert booking;
    

        List<SetBookingName.Request> reqlist= new List<SetBookingName.Request>();
        SetBookingName.Request req= new SetBookingName.Request();
        req.bookingId = booking.id;
         
        reqlist.add(req);
        Test.startTest();
        SetBookingName.execute(reqlist);
        //SetBookingName.generateFieldValueMap(fieldValues,'Name');
        Test.stopTest();
    }
    
         @isTest
    static void ReqTestMethod2(){
       Map<String, Object> fieldValues = new Map<String, Object>();
        
        Unit__c unit01 = new Unit__c();
        unit01.Name = 'TestUnit01';
     
        unit01.Carpet_Area__c = 1000;
       
        unit01.Unit_UOM__c = 'Feet';
        unit01.Size_Range__c = 'below 10000';
        insert unit01;
        
        Unit__c unit02 = new Unit__c();
        unit02.Name = 'TestUnit02';
       
        unit02.Unit_UOM__c = 'Feet';
        unit02.Size_Range__c = 'below 10000';
             
        insert unit02;

       

        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                  .get('Person Account').getRecordTypeId();

        Account personAcct = new account();
        personAcct.lastName = 'ginny';
        personAcct.RecordTypeId = recordTypeId;
        insert personAcct;

        Opportunity__c opp = new Opportunity__c();
        //opp.Account_Name__c = personAcct.id;
        opp.Name = 'TestOpp';
        opp.Close_Date__c = system.today() + 7;
        opp.Stage__c = 'In Progress'; 
        insert opp;
        Shortlisted_Unit__c shortUnit01 = new Shortlisted_Unit__c();
        shortUnit01.Status__c = 'Booked';
        shortUnit01.Unit__c = unit01.id;
       // shortUnit01.Opportunity__c = opp.id;
        insert shortUnit01;

        Shortlisted_Unit__c shortUnit02 = new Shortlisted_Unit__c();
        shortUnit02.Status__c = 'Booked';
        shortUnit02.Unit__c = unit02.id;
        //shortUnit02.Opportunity__c = opp.id;
        insert shortUnit02;

       

        Unit_Bundle__c unitBundle = new Unit_Bundle__c();
      //  unitBundle.Opportunity__c = opp.Id;
        unitBundle.Name = 'TestUnitBundle';
       
        unitBundle.Linked_Unit__c = '["' + shortUnit01.id + '","' + shortUnit02.id + '"]';
        insert unitBundle;

         Booking__c booking = new Booking__c();
        booking.Booking_Date__c = System.today();
        //booking.Related_Opportunity1__c = opp.Id;
        insert booking;
        
       List<SetBookingName.Request> reqlist= new List<SetBookingName.Request>();
        SetBookingName.Request req= new SetBookingName.Request();
        req.bookingId = booking.id;
         
        reqlist.add(req);
        Test.startTest();
        SetBookingName.execute(reqlist);
        SetBookingName.generateFieldValueMap(fieldValues,'');
        Test.stopTest();
    }    
}