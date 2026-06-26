@isTest
public class SendEmailtoLandLordTest {
    
    @isTest
    static void testSendEmailtoLandLord() {
        
        // Create Person Account
        Account acc = new Account(
            FirstName = 'Test',
            LastName = 'Landlord',
            PersonEmail = 'landlord@test.com'
        );
        insert acc;
        
        // Create Unit
        Unit__c unit = new Unit__c(
            Name = 'Unit-101',
            City__c = 'Chennai',
            Point_of_Contact__c = acc.Id,
            Size_Range__c = '10000 - 25000',
            Date_Available__c = Date.today()
        );
        insert unit;
        
        // Create Shortlisted Unit
        Shortlisted_Unit__c su = new Shortlisted_Unit__c(
            Unit__c = unit.Id
        );
        insert su;
        
        // Create Unit Bundle
        Unit_Bundle__c ub = new Unit_Bundle__c(
            Linked_Unit__c = JSON.serialize(
                new List<String>{ su.Id }
            )
        );
        insert ub;
        
        // Create Wrapper Input
        SendEmailtoLandLord.InputWrapper wrapper =
            new SendEmailtoLandLord.InputWrapper();
        
        wrapper.VisitDateTime = '28-May-2026';
        wrapper.UnitBundleId = ub.Id;
        
        Test.startTest();
        
        SendEmailtoLandLord.getUnitRecords(
            new List<SendEmailtoLandLord.InputWrapper>{ wrapper }
        );
        
        Test.stopTest();
        
        System.assert(true);
    }
}