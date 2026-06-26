/**
* @File Name : InterestedLocationGeoController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 12, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 12, 2025 |   | Initial Version
**/

public class InterestedLocationGeoController {
    private static Boolean isExecuted = false;
	public static void getGeoupdateMethod(List<Interested_Locations__c> records){
		Set<Id> recoId = new Set<Id>();
		for(Interested_Locations__c intrec: records){
            if(intrec.Address__Latitude__s ==null || intrec.Address__Longitude__s == null ){
                recoId.add(intrec.Id);
            }
            	
		}
		if(!recoId.IsEmpty()){
			List<Id> Idlist = new List<Id>();
			Idlist.addAll(recoId);
            
            if(!isExecuted){
                InterestedLocationGeoController.getGeoMethod(Idlist);
            }
            
		}
	}

	@future(callout =true)
	public static void getGeoMethod(List<Id> recId){
        isExecuted=true;
		List<Interested_Locations__c> records =[SELECT Id, Address__c FROM Interested_Locations__c Where Id=:recId];
		 List<Interested_Locations__c> updateInterestLoc = new List<Interested_Locations__c>();
		 String apiKey ='0accacabb1b648be9cd7b5a742a79a10';
        for (Interested_Locations__c inteLoc : records) {
            HttpRequest req = new HttpRequest();
            String urlParameters = '';
            /* Avoid using street as the api does not have info of all streets
             * (String.isNotBlank(account.BillingStreet)){
                urlParameters += '&street='+EncodingUtil.urlEncode(account.BillingStreet, 'UTF-8');
            }*/
            if(String.isNotBlank(inteLoc.Address__c.getCity())){
				if(urlParameters !=''){
					urlParameters += ','+inteLoc.Address__c.getCity();
				}else{
					urlParameters += inteLoc.Address__c.getCity();
				}
                
            }
            
            if(String.isNotBlank(inteLoc.Address__c.getState())){
				if(urlParameters !=''){
                urlParameters += ','+inteLoc.Address__c.getState();
				}else{
					urlParameters += inteLoc.Address__c.getState();
				}
            }
			if(String.isNotBlank(inteLoc.Address__c.getCountry())){
				if(urlParameters !=''){
                urlParameters += ','+inteLoc.Address__c.getCountry();
				}else{
					urlParameters += inteLoc.Address__c.getCountry();
				}
            }
            if(String.isNotBlank(inteLoc.Address__c.getPostalCode())){
				if(urlParameters !=''){
                urlParameters += ','+inteLoc.Address__c.getPostalCode();
				}else{
					urlParameters += inteLoc.Address__c.getPostalCode();
				}
            }

            
            String url = 'https://api.geoapify.com/v1/geocode/search?text=' +
                EncodingUtil.urlEncode(urlParameters ,'UTF-8')+'&apiKey='+apiKey;
            
            req.setEndpoint(
                url
            );
            
            req.setMethod('GET');
			req.setTimeout(60000);
            
            Http http = new Http();
            HttpResponse res;
            if(!Test.isRunningTest()){
                res = http.send(req);
            } else {
                res = new HttpResponse();
                res.setStatusCode(200);
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"features": [{ "geometry": {"coordinates": [80.0759706, 12.8629364]},"properties": {"formatted": "Test Address"}}]}');
			}

            System.debug(res.getBody());
            
            GeoResult geoDataJson;
            try {
                geoDataJson = extractGeoData(
                    res.getBody()
                );  
				system.debug('result One : '+geoDataJson);
            } catch (Exception ex) {
                System.debug('Exception : ' + ex);
            }
            if (geoDataJson != null) {
                updateInterestLoc.add(
                    new Interested_Locations__c(
                        Id = inteLoc.Id,
                        Address__Latitude__s = geoDataJson.latitude,
                        Address__Longitude__s = geoDataJson.longitude
                    )
                );
            }
        }
		system.debug('update record : '+updateInterestLoc);
        
        update updateInterestLoc;
	}
    
    public static GeoResult extractGeoData(String jsonBody) {
        GeoResult result = new GeoResult();

        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
            List<Object> features = (List<Object>) parsed.get('features');

            if (features != null && !features.isEmpty()) {
                Map<String, Object> firstFeature = (Map<String, Object>) features[0];

                // Extract coordinates
                Map<String, Object> geometry = (Map<String, Object>) firstFeature.get('geometry');
                List<Object> coordinates = (List<Object>) geometry.get('coordinates');
                result.longitude = (Decimal) coordinates[0];
                result.latitude = (Decimal) coordinates[1];

                // Optional: get formatted address
                Map<String, Object> properties = (Map<String, Object>) firstFeature.get('properties');
                result.formattedAddress = (String) properties.get('formatted');

                return result;
            }
        } catch (Exception e) {
            System.debug('Failed to parse Geoapify response: ' + e.getMessage());
        }

        return null;
    }
	
    public class GeoResult {
        public Decimal latitude;
        public Decimal longitude;
        public String formattedAddress;
    }
}