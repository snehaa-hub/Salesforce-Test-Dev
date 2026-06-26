@isTest
public class getUnitOption_Test {
	@isTest
    static void testGetUnitOptionId() {
        // Create Opportunity
        Opportunity__c opp = new Opportunity__c(Name = 'Test Opp');
        insert opp;

        // Create Unit (to be matched)
        Unit__c matchingUnit = new Unit__c(Name = 'Matching Unit');
        insert matchingUnit;

        // Create another Unit (non-matching)
        Unit__c nonMatchingUnit = new Unit__c(Name = 'Other Unit');
        insert nonMatchingUnit;

        // Create Unit_Bundle__c with Linked_Unit__c = ["matchingUnit.Id"]
        Unit_Bundle__c unitBundle = new Unit_Bundle__c(
            Name = 'Test Bundle',
            Opportunity__c = opp.Id,
            Linked_Unit__c = '["' + matchingUnit.Id + '"]'
        );
        insert unitBundle;

        // Create two requests — one match, one no match
        getUnitOption.Request matchReq = new getUnitOption.Request();
        matchReq.oppId = opp.Id;
        matchReq.shortlistedUnitId = matchingUnit.Id;

        getUnitOption.Request noMatchReq = new getUnitOption.Request();
        noMatchReq.oppId = opp.Id;
        noMatchReq.shortlistedUnitId = nonMatchingUnit.Id;

        List<getUnitOption.Request> reqList = new List<getUnitOption.Request>{ matchReq, noMatchReq };

        // Call the method
        List<getUnitOption.Response> responses = getUnitOption.getUnitOptionId(reqList);

        // Assert
        System.assertEquals(2, responses.size(), 'Should return two responses');
        System.assertEquals(unitBundle.Id, responses[0].unitOptionId, 'First response should match the unit bundle');
        System.assertEquals(null, responses[1].unitOptionId, 'Second response should be null (no match)');
    }
}