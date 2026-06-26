/**
 * @description This class is used to get object name on the basis of recordId
 */
global class GetObjectName {

	/**
	 * @description This method is used in lwc to get object name on the basis of recordId
	 * @param recordId
	 * @return objectName
	 */
    @AuraEnabled(cacheable=true)
    global static String getObject(Id recordId){	
        String objectName = recordId.getSObjectType().getDescribe().getName();
        return objectName;
    }
    
	/**
	 * @description This method is used as invocable method in flows to get object name on the basis of recordId
	 * @param requestLst
	 * @return list of response (Wrapper)
	 */
	@InvocableMethod(label='Get Object Name' description='Get Object Name')
	global static List<Response> execute(List<Request> requestLst){	
		List<Response> responseList = new List<Response>();

		for(Request req : requestLst){ 

			Response res = new Response();
            res.objectName = (req.recordId).getSObjectType().getDescribe().getName();
			responseList.add(res);
		}

		return responseList;
	}

	/**
	 * @description Wrapper class for input record id through flow
	 */
	global class Request{

		@InvocableVariable(label = 'Record Id' description = 'Record Id' required = true)
		global Id recordId;
	}

	/**
	 * @description Wrapper class for output objectname to flow
	 */
	global class Response{

		@InvocableVariable(label = 'Object API Name' description = 'Object API Name')
		global String objectName;
	}
}