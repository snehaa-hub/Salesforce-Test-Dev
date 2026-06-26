@isTest
public class extractShortlistedUnitIdTest {
	@isTest
    static void testValidJson() {
        extractShortlistedUnitIdFromUnitOption.Request req = new extractShortlistedUnitIdFromUnitOption.Request();
        req.jsonString = '["a0B1x00000123AB"]';

        List<extractShortlistedUnitIdFromUnitOption.Request> requestList = new List<extractShortlistedUnitIdFromUnitOption.Request>{ req };

        Test.startTest();
        List<extractShortlistedUnitIdFromUnitOption.Response> responseList = extractShortlistedUnitIdFromUnitOption.parseFirstId(requestList);
        Test.stopTest();

        System.assertEquals(1, responseList.size());
        System.assertEquals('a0B1x00000123AB', responseList[0].firstId);
    }

    /*@isTest
    static void testBlankJson() {
        extractShortlistedUnitIdFromUnitOption.Request req = new extractShortlistedUnitIdFromUnitOption.Request();
        req.jsonString = '';  // Blank input

        List<extractShortlistedUnitIdFromUnitOption.Request> requestList = new List<extractShortlistedUnitIdFromUnitOption.Request>{ req };

        List<extractShortlistedUnitIdFromUnitOption.Response> responseList = extractShortlistedUnitIdFromUnitOption.parseFirstId(requestList);

        System.assertEquals(1, responseList.size());
        System.assertEquals(null, responseList[0].firstId);  // Should remain null
    }

    @isTest
    static void testInvalidJson() {
        extractShortlistedUnitIdFromUnitOption.Request req = new extractShortlistedUnitIdFromUnitOption.Request();
        req.jsonString = '{"invalid": "json"}';  // Invalid for expected list format

        List<extractShortlistedUnitIdFromUnitOption.Request> requestList = new List<extractShortlistedUnitIdFromUnitOption.Request>{ req };

        Test.startTest();
        List<extractShortlistedUnitIdFromUnitOption.Response> responseList = extractShortlistedUnitIdFromUnitOption.parseFirstId(requestList);
        Test.stopTest();

        System.assertEquals(1, responseList.size());
        System.assertEquals(null, responseList[0].firstId);  // Should catch the error and skip assigning
    }*/
}