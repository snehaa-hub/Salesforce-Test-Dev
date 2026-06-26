@isTest
public class TestInboundLeadHandler {

    @isTest
    static void testInboundLeadSuccess() {
        // Step 1: Create mock JSON input matching expected format
        String jsonInput = '{"Leads":[{' +
            '"FirstName":"Ramjith",' +
            '"LastName":"Test",' +
            '"Phone":"9876543210",' +
            '"Email":"test@example.com",' +
            '"Project":"Valley",' +
            '"Campaign":"SummerCampaign",' +
            '"Source":"99Acres",' +
            '"Medium":"Web",' +
            '"Term":"Flats",' +
            '"Content":"ContentValue",' +
            '"Locality":"Chennai",' +
            '"BHK":"2 BHK"' +
        '}]}';

        // Step 2: Simulate the RestContext for testing
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;

        // Step 3: Call the handler
        Test.startTest();
        InboundLeadHandler.handleInboundLead();
        Test.stopTest();

        // Step 4: Assert that an Enquiry__c record was inserted
        List<Enquiry__c> insertedEnquiries = [
            SELECT Name, Mobile__c, Email__c, Enquiry_Source__c, Enquiry_Sub_Source__c, Comment__c 
            FROM Enquiry__c 
            WHERE Email__c = 'test@example.com'
        ];

        System.assertEquals(1, insertedEnquiries.size(), 'One enquiry should be inserted');
        System.assertEquals('RamjithTest', insertedEnquiries[0].Name);
        System.assertEquals('9876543210', insertedEnquiries[0].Mobile__c);
        System.assertEquals('99 Acres', insertedEnquiries[0].Enquiry_Sub_Source__c);
    }
}