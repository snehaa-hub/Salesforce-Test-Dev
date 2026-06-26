@isTest
public class PostInspectionServiceTest {

    @isTest
    static void testSendReport_FullFlow() {
        // Record Type
        Id enqRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Enquiry__c' AND Name = 'Tenant' LIMIT 1].Id;

        //Enquiry
        Enquiry__c enq = new Enquiry__c(
            Name = 'K Gandhi',
            RecordTypeId = enqRT,
            Email__c = 'ram@gmail.com',
            Mobile__c = '919080715921',
            Status__c = 'New',
            Size_in_sqft__c = '10000 - 25000',
            Size_in_sqfts__c = 10050,
            Type_of_Unit__c = 'Land'
        );
        insert enq;

        // Required child 
        insert new Interested_Locations__c(
            Name = 'Test Location',
            Related_Enquiry__c = enq.Id,
            Interested_Location_Range__c = 5
        );

        // Trigger Opportunity creation
        enq.Status__c = 'Closed';
        enq.Reason_for_Closed__c = 'Qualified';
        update enq;

        // Get Opportunity
        Opportunity__c opp = [SELECT Id FROM Opportunity__c WHERE Enquiry__c = :enq.Id LIMIT 1];

        Site_Visit__c sv = new Site_Visit__c(
            Name = 'Visit 1',
            Opportunity__c = opp.Id,
            Status__c = 'Completed',
            Visit_Date_Time__c = System.now().addMinutes(10),
            Created_From__c = 'API',
            No_of_People_Planned__c = 2
        );
        insert sv;

        Site_Visit__c svFromDB = [
            SELECT Site_Visit_Status__c, Visit_Date__c
            FROM Site_Visit__c
            WHERE Id = :sv.Id
        ];

        System.assertEquals('Completed',svFromDB.Site_Visit_Status__c,'Status should be Completed');

        System.assertEquals(Date.today(),svFromDB.Visit_Date__c,'Visit Date should be today');


        List<Site_Visit__c> visitsCheck = [
            SELECT Id 
            FROM Site_Visit__c
            WHERE Opportunity__c = :opp.Id
            AND Site_Visit_Status__c = 'Completed'
            AND Visit_Date__c = TODAY
        ];

        System.assert(visitsCheck.size() > 0,'Visit should match filter conditions');
        Test.startTest();
        PostInspectionService.sendReport(new List<String>{opp.Id});
        Test.stopTest();
        System.assertEquals(0,Limits.getEmailInvocations(),'Email should be sent when conditions match');
    }
}