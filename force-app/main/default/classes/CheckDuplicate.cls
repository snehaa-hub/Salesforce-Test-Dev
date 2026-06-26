/**
 * @description This class is used to check duplicate Records on the basis of duplicate rule
 */
global without sharing class CheckDuplicate {
    
	/**
     * @description This method validates duplicate Records
     * @param requestLst
	 * @return deuplicate record Id if exist
     */
    @InvocableMethod(label='Check Duplicate' description='Check Duplicate')
	global static List<Response> execute(List<Request> requestLst){	
		List<Response> duplicateRecords = new List<Response>();

		for(Request req : requestLst){ 

			Response res = new Response();
			res.recordId = req.record.Id;
			Id duplicateRecordId = duplicateChecker(req.record);

			if(duplicateRecordId == null){
				res.duplicateRecordId = null;
			}
			else{
                res.duplicateRecordId = duplicateRecordId;
			}

			duplicateRecords.add(res);
		}

		return duplicateRecords;
	}

	/**
     * @description This is helping method that validates duplicate Records
     * @param record
	 * @return duplicate recordId
     */
	private static Id duplicateChecker(SObject record){
		List<SObject> recordList = new List<SObject>();
		recordList.add(record);
		List<Datacloud.FindDuplicatesResult> results;
        
        try {
            results = Datacloud.FindDuplicates.findDuplicates(recordList);
        } catch (Exception ex) {
            return null;
        }
        
		for(Datacloud.FindDuplicatesResult findDupeResult : results){
			for(Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()){
				for(Datacloud.MatchResult matchResult : dupeResult.getMatchResults()){
                    for(Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()){
                        return matchRecord.getRecord().Id;
                    }
				}
			}
		}

		return null;
	}

	/**
	 * @description This is wrapper that is used to input required values in class
	 */
	global class Request{

		@InvocableVariable(label = 'Record' description = 'Record for Duplication Checks' required = true)
		global SObject record;
	}

	/**
	 * @description This is wrapper that is used to return required values from class
	 */
	global class Response{

		@InvocableVariable(label = 'Duplicate Record Id' description = 'Record Id of Duplicate Record')
		global Id duplicateRecordId;

		@InvocableVariable(label = 'Record Id' description = 'Record Id that was checked for duplicates')
		global Id recordId;
	}
    
}