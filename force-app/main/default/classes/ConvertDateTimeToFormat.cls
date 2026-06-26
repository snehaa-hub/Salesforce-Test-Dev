/**
 * @description This class is used to convert a data/Time value in a specific format
 */
global class ConvertDateTimeToFormat {
	 
    /**
     * @description This method is used  to convert a data/Time value in a specific format by passing date/Time value and format
     * @return formated Date/Time
     * @param requestLst
     */
    @InvocableMethod(label='Convert Date-Time To Format' description='Convert Date-Time To Format')
	global static List<Response> execute(List<Request> requestLst){
        List<Response> responseList = new List<Response>();
		for(Request req : requestLst){ 
            Response res = new Response();
            res.formatedDateTime = (req.value).format(req.format);
            responseList.add(res);
        }
        return responseList;
    }
    
    /**
	 * @description This is wrapper that is used to input required values in class
	 */
    global class Request{

		@InvocableVariable(label = 'Value' description = 'Value for Conversion' required = true)
		global DateTime value;
        
        @InvocableVariable(label = 'Format' description = 'Format of DateTime' required = true)
		global String format;
	}

    /**
	 * @description This is wrapper that is used to return required values from class
	 */
	global class Response{

		@InvocableVariable(label = 'Formated Date Time' description = 'Formated Date Time')
		global String formatedDateTime;
	}
}