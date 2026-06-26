/**
* @File Name : extractShortlistedUnitIdFromUnitOption.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 28, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 28, 2025 |   | Initial Version
**/

public class extractShortlistedUnitIdFromUnitOption {
	public class Request {
        @InvocableVariable(required=true)
        public String jsonString;
    }

    public class Response {
        @InvocableVariable
        public String firstId;
    }

    @InvocableMethod(label='Parse First Id from JSON Array')
    public static List<Response> parseFirstId(List<Request> requests) {
        List<Response> results = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            if (!String.isBlank(req.jsonString)) {
                try {
                    List<Object> idList = (List<Object>) JSON.deserializeUntyped(req.jsonString);
                    if (!idList.isEmpty()) {
                        res.firstId = (String) idList[0];
                    }
                } catch (Exception e) {
                    System.debug('JSON parse error: ' + e.getMessage());
                }
            }
            results.add(res);
        }
        return results;
    }
}