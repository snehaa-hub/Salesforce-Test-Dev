@isTest
public class GetNegotiationChecklistMetadata_Test {
    @isTest
    static void testExecute() {
        Test.startTest();
        List<Object> result = GetNegotiationChecklistMetadata.execute();
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.debug('Metadata records returned: ' + result.size());
    }
}