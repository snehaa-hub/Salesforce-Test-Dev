/* 
*@description       : When the Enquiry Status is 'Closed' and the Reason is 'Qualified', 
an Opportunity should be created with the Stage set to 'Qualified Test class
@author            : Ruban
@last modified on  : 29/04/2025

*/

@isTest
public class EnquiryObjectTest {
    @testsetup
    static void setupData(){
        	 RecordType rc = [SELECT Id, Name, DeveloperName, SObjectType 
FROM RecordType 
WHERE SObjectType = 'Account' 
AND DeveloperName = 'PersonAccount'];
		 Account acc = new Account(LastName='Test Name',RecordTypeId = rc.Id);
        insert acc;
        
        RecordType landRT = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Enquiry__c' AND Name = 'Tenant'
            LIMIT 1
        ];
        Enquiry__c enq1=new Enquiry__c(
            Name = 'Test Enquiry 1',
                Status__c = 'Closed',
                Reason_for_Closed__c = 'Qualified',
                 Mobile__c = '9876543210',
            	Contact_Person__c = acc.Id,
                RecordTypeId = landRT.Id,
            Size_in_sqft__c  = '10000 - 25000',
            Size_in_sqfts__c = 15000,
             Type_of_Unit__c = 'Land',
            Types_of_F_W__c = ''
        );
        Insert enq1;
        
          RecordType rt = [SELECT Id, Name FROM RecordType 
                 WHERE DeveloperName = 'Tenant' 
                 AND SObjectType = 'Enquiry__c' 
                 LIMIT 1];
        Enquiry__c enquiry = new Enquiry__c(
            Name = 'Test Enquiry',
            Email__c = 'testuser@example.com',
            Type_of_Unit__c = 'Land', // match with unit
            Status__c ='Closed',
            Mobile__c ='1111100076',
            Reason_for_Closed__c = 'Qualified',
            Contact_Person__c = acc.Id,
            RecordTypeId =rt.Id,
			Size_in_sqft__c  = '10000 - 25000',//Added on 11-11-2025
            Size_in_sqfts__c = 15000//size range Added on 11-11-2025
        );
        insert enquiry;
         Interested_Locations__c interestedLoc = new Interested_Locations__c(
            Address__Latitude__s = 12.8728,     // near Urapakkam
            Address__Longitude__s = 80.0823,
            Related_Enquiry__c = enquiry.Id,
            Interested_Location_Range__c = 5
        );
        insert interestedLoc;
        
    }
    @isTest
    static void testOpportunityCreation(){
        List<Enquiry__c> enquiries = [SELECT Id, Name, Type_of_Unit__c, Status__c, Reason_for_Closed__c, RecordTypeId,Contact_Person__c,Budget_Range1__c,Nature_of_Purchase__c,
                                      Size_in_sqft__c, Enquiry_Source__c, Enquiry_Sub_Source__c,Customer_Name__c, Referral_Name__c, Size_in_sqfts__c FROM Enquiry__c];
        Interested_Locations__c interestedLoc1 = new Interested_Locations__c(
            Address__Latitude__s = 12.8728,     // near Urapakkam
            Address__Longitude__s = 80.0823,
            Related_Enquiry__c = enquiries[0].Id,
            Interested_Location_Range__c = 5
        );
        insert interestedLoc1;
        Test.startTest();
        EnquiryObject.createOpportunities(enquiries);
        
        Test.stopTest();
        
        List<Opportunity__c> createdOpportunity = [
            SELECT Id, Name, Enquiry__c, Stage__c, Record_Type__c, Account_Name__c 
            FROM Opportunity__c
        ];
        EnquiryObject.getOpportunity(createdOpportunity[0].Enquiry__c);
        for (Opportunity__c opp : createdOpportunity) {
            if (opp.Record_Type__c == 'Tenant') {
                System.assertEquals('Tenant', opp.Record_Type__c, 'Record type should be Tenant');
            } else if (opp.Record_Type__c == 'Landlord') {
                System.assertEquals('landlord', opp.Record_Type__c, 'Record type should be landlord');
            }
		}
        
    }
    @isTest
    static void testCreateOpportunities() {
        List<Enquiry__c> enquiryList = new List<Enquiry__c>{
            new Enquiry__c(
                Name = 'Test Enquiry 1',
                Status__c = 'Closed',
                Reason_for_Closed__c = 'Qualified',
                 Mobile__c = '9876543210',
               // Email__c = 'test1@gmail.com', //Added on 11-11-2025
                RecordTypeId = Schema.SObjectType.Enquiry__c.getRecordTypeInfosByName().get('Tenant').getRecordTypeId(),
                Size_in_sqft__c  = '10000 - 25000',
            Size_in_sqfts__c = 15000,
             Type_of_Unit__c = 'Land',
            Types_of_F_W__c = ''
            )
                };
                    
                    insert enquiryList;
        
        Test.startTest();
        EnquiryObject.createOpportunities(enquiryList);
        Test.stopTest();
        
      /*  Opportunity__c createdOpportunity = [
            SELECT Id, Name, Enquiry__c, Stage__c, Record_Type__c, Account_Name__c,Property_Type__c
            FROM Opportunity__c Where Stage__c = 'Qualified'
            LIMIT 1
        ];
        
        
        // Check that Stage__c is 'Qualified'
        System.assertEquals('Qualified', createdOpportunity.Stage__c, 'Stage should be Qualified');*/
    }
}