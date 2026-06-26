/**
* @File Name : getUnitOption.cls
* @Description : get unit option to find out that whether this unit option has unit or not
* @Author :
* @Last Modified By :
* @Last Modified On : June 19, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 19, 2025 |   | Initial Version
**/

public class getUnitOption {
	@InvocableMethod(label = 'Get Unit Option')
	public static List<Response> getUnitOptionId(List<Request> reqList){
		List<Response> responseList = new List<Response>();

    for(Request req : reqList){ 
        // Step 1: Build query (only filter on Opportunity)
        String unitOptionQuery = 'SELECT Id, Name, Linked_Unit__c FROM Unit_Bundle__c';
        if (!String.isBlank(req.oppId)) {
            unitOptionQuery += ' WHERE Opportunity__c = \'' + String.escapeSingleQuotes(req.oppId) + '\'';
        }

        // Step 2: Execute query
        List<Unit_Bundle__c> unitOptions = Database.query(unitOptionQuery);

        // Step 3: Filter records based on exact match of the ID inside Linked_Unit__c string
        Response res = new Response();
        String expectedFormat = '["' + req.shortlistedUnitId + '"]'; // exact match format
		System.debug('expectedFormat' +expectedFormat);
        for (Unit_Bundle__c ub : unitOptions) {
			System.debug('ub.Linked_Unit__c: ' + ub.Linked_Unit__c);
            if (ub.Linked_Unit__c != null && ub.Linked_Unit__c.trim() == expectedFormat) {
                res.unitOptionId = ub.Id;
				System.debug('ub.Id' +ub.Id);
                break;
            }
        }
		
        responseList.add(res);
		System.debug('38 responseList' +responseList);
    }

    return responseList;
	}

	public class Request{
		@InvocableVariable(label = 'Opportunity Id' required=true)
		public string oppId;

		@InvocableVariable(label = 'Shortlisted Unit Id')
		public string shortlistedUnitId;

	}
	public class Response {
        @InvocableVariable(label='Unit Bundle Ids' required=true)
        public String unitOptionId;
    }
}