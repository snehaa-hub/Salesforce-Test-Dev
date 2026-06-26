public class UnitTriggerHandler {
    @AuraEnabled(cacheable=true)
     public static Unit__c getUnitList(String UnitId){
        Unit__c unit = [SELECT Id, Name,Unit_Number__c,DuplicateUnitName__c,Allow_this_unit__c, Type_of_Unit__c,Unit_Location__c, Unit_Location__Latitude__s, Unit_Location__Longitude__s FROM Unit__c Where Id=:UnitId];
        return unit;
     }
    public static Void interestEnquiriesNotification(List<Unit__c> unitList,Map<Id,Unit__c>oldMap){
        if(!unitList.isEmpty()){


            Set<Interested_Locations__c> intLocWithinRadius = new Set<Interested_Locations__c>();
            Map<Id,Unit__c> unitNameforIntLoc = new Map<Id,Unit__c>();
            List<Interested_Locations__c> interestrecords =[SELECT Id, Address__c,Address__Latitude__s,Address__Longitude__s,Related_Enquiry__c,Related_Enquiry__r.Type_of_Unit__c,Interested_Location_Range__c FROM Interested_Locations__c Where Address__Latitude__s != null AND Address__Longitude__s != null AND Related_Enquiry__r.Reason_for_Closed__c ='Qualified' ];
            for (Unit__c unitrec : unitList) {
            // Check if location has changed or is newly set
            Boolean locationChanged = oldMap != null && 
                                    oldMap.containsKey(unitrec.Id) &&
                                    unitrec.Unit_Location__c != oldMap.get(unitrec.Id).Unit_Location__c;

            Boolean locationAvailable = unitrec.Google_Coordinates_Link__c != null  && unitrec.Unit_Location__Latitude__s != null && unitrec.Unit_Location__Longitude__s != null;

            if ((locationChanged || locationAvailable) && locationAvailable) {
                Double centerLatitude = unitrec.Unit_Location__Latitude__s;
                Double centerLongitude = unitrec.Unit_Location__Longitude__s;
                

                Location centerLocation = Location.newInstance(centerLatitude, centerLongitude);

                for (Interested_Locations__c intLoc : interestrecords) {
                    if(intLoc.Related_Enquiry__r.Type_of_Unit__c == unitrec.Type_of_Unit__c){
                        if (intLoc.Address__Latitude__s != null && intLoc.Address__Longitude__s != null) {
                            Double intLocLatitude = intLoc.Address__Latitude__s;
                            Double intLocLongitude = intLoc.Address__Longitude__s;
                            Double radiusInKm = intLoc.Interested_Location_Range__c !=null?(Double) intLoc.Interested_Location_Range__c:5.0;
                            System.debug('debug radiusInKm :'+radiusInKm);
                            Location intLocLocation = Location.newInstance(intLocLatitude, intLocLongitude);
                            System.debug('debug intLocLocation :'+intLocLocation);
                            System.debug('debug centerLocation :'+centerLocation);
                            Double distance = Location.getDistance(centerLocation, intLocLocation, 'km');
                            System.debug('debug distance :'+distance);
                            if (distance <= radiusInKm) {
                                intLocWithinRadius.add(intLoc);
                                unitNameforIntLoc.put(intLoc.Related_Enquiry__c,unitrec);
                            }
                        }
                    }
                    
                }
            } else {
                System.debug('Skipping Unit__c record: missing or unchanged location.');
            }
        }

            System.debug('radius records :'+intLocWithinRadius);
            Set<Id> enquiryId = new Set<Id>();
            for (Interested_Locations__c intLocs : intLocWithinRadius) {
                enquiryId.add(intLocs.Related_Enquiry__c);
            }
            List<Enquiry__c> enquiryRecords = [SELECT Id,Name,Type_of_Unit__c, Email__c,Size_in_sqft__c From Enquiry__c Where Id=:enquiryId AND Email__c !=null];
            notifyEnquiriesForNewUnit(enquiryRecords,unitNameforIntLoc);
        }

    }
    
    public static Void checkDuplicateUnitBeforeInsert(List<Unit__c> unitList,Map<Id,Unit__c>oldMap){
        if(!unitList.IsEmpty()){
            if(oldMap == null){
                for(Unit__c unit:unitList){
                    unit.Allow_this_unit__c = false;
                    unit.DuplicateUnitName__c ='';
                }
            } else{
                 for(Unit__c unit:unitList){
                     if(unit.Type_of_Unit__c != oldMap.get(unit.Id).Type_of_Unit__c || unit.Google_Coordinates_Link__c != oldMap.get(unit.Id).Google_Coordinates_Link__c )
                    unit.Allow_this_unit__c = false;
                   // unit.DuplicateUnitName__c ='';
                }
            }
        }
        
    }

    public static void checkDuplicateNewUnit(List<Unit__c> unitList) {
        Set<Id> unitId = new Set<Id>();
                for (Unit__c newUnita : unitList) {
                    unitId.add(newUnita.Id);
                }
                            // Check if another unit exists within 100 meters
                List<Unit__c> allUnitsWithLocation = [SELECT Id, Name,Unit_Number__c, Type_of_Unit__c,Unit_Location__c, Unit_Location__Latitude__s, Unit_Location__Longitude__s FROM Unit__c 
                                                    WHERE Unit_Location__Latitude__s != null AND Unit_Location__Longitude__s != null];
                List<Unit__c> updateunitrec = new  List<Unit__c>();
                for (Unit__c newUnit : unitList) {
                    if (newUnit.Unit_Location__Latitude__s != null && newUnit.Unit_Location__Longitude__s != null) {
                        Location newLoc = Location.newInstance(newUnit.Unit_Location__Latitude__s, newUnit.Unit_Location__Longitude__s);
                        
                        for (Unit__c existingUnit : allUnitsWithLocation) {
                            // Skip comparing with itself (for update scenarios)
                            if (existingUnit.Id != newUnit.Id && existingUnit.Type_of_Unit__c == newUnit.Type_of_Unit__c) {
                                Location existingLoc = Location.newInstance(existingUnit.Unit_Location__Latitude__s, existingUnit.Unit_Location__Longitude__s);
                                Double distance = Location.getDistance(newLoc, existingLoc, 'km');
                                System.debug('distance '+distance+' unit number '+newUnit.Unit_Number__c+' existingUnit.Unit_Number__c '+existingUnit);
                                if (distance <= 0.1  && newUnit.Allow_this_unit__c == false) { // 100 meters
                                    // Throw error using ApexPages or addError for trigger-level enforcement
                                   // newUnit.addError('Another unit exists within 100 meters with the same Type of Unit: ' + existingUnit.Name);
                                   System.debug('distance within the unit');
                                   newUnit.Allow_this_unit__c = true;
                                   newUnit.DuplicateUnitName__c = existingUnit.Unit_Number__c;
                                   updateunitrec.add(newUnit);
                                }
                            }
                        }
                    }
                }
                update updateunitrec;
    }

    public static void notifyEnquiriesForNewUnit(List<Enquiry__c> enquiries,Map<Id,Unit__c> unitrecMap) {
        if(!enquiries.isEmpty()){
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
             OrgWideEmailAddress owea = [
                SELECT Id
                FROM OrgWideEmailAddress
                WHERE Address = 'chennai@allwarehouses.in'
                LIMIT 1
            ];
            for(Enquiry__c enq:enquiries){
                Unit__c unit = unitrecMap.get(enq.Id);
                String toAddress = enq.Email__c;
                String subject = 'New '+enq.Type_of_Unit__c+' Available Near Your Interested Location';
                Boolean isSizeEqual = enq.Size_in_sqft__c == unit.Size_Range__c?true:false;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] { toAddress });
                    mail.setCcAddresses(new List<String>{ 'pooja@allwarehouses.in', 'chennai@allwarehouses.in' });
                    mail.setOrgWideEmailAddressId(owea.Id);
                    mail.setSubject(subject);
                    mail.setPlainTextBody(
                        'Hello,\n\nA new '+enq.Type_of_Unit__c+' has been added within your interested location range.\n\n' +
                        'Please check with Shailaja Kumari (+91 740 111 6666) for futher contact. \n\nCreated Unit Number : '+unit.Unit_Number__c+'.\n\nThank you!'
                    );
                    //emailsToSend.add(mail);
            }
             if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
            System.debug('Emails sent: ' + emailsToSend.size());
        } else {
            System.debug('No matching enquiries found within 5 km radius.');
        }
        }

    }
    public static Void GeoCoordinatesExtractor(List<Unit__c> unitList,Map<Id,Unit__c>oldMap) {
        set<String> UnitLocationId = new Set<String>();
        system.debug('unitList'+unitList);
        system.debug('unitList'+oldMap);
        for(Unit__c thisUnit: unitList)
        {
          
            if(thisUnit.Google_Coordinates_Link__c != '' && thisUnit.Google_Coordinates_Link__c != null){
               // System.debug('Google_Coordinates_Link__c oldMap '+oldMap.KeySet().IsEmpty());

                if(oldMap == null)
                {
                     System.debug('Google_Coordinates_Link__c new '+thisUnit.Google_Coordinates_Link__c);
                    UnitLocationId.add(thisUnit.Id);
                }
                else if(thisUnit.Google_Coordinates_Link__c != oldMap.get(thisUnit.Id).Google_Coordinates_Link__c)
                {
            System.debug('Google_Coordinates_Link__c old '+thisUnit.Google_Coordinates_Link__c);
                    UnitLocationId.add(thisUnit.Id);
                    
                }
            }
        }
        System.debug('UnitLocationId '+UnitLocationId);
		if(!UnitLocationId.IsEmpty()){
            system.debug('unitList'+UnitLocationId);
			UnitTriggerHandler.updateGoogleCordinatesLink(UnitLocationId);
		}
       
    }
    @future(callout=true)
    public Static Void updateGoogleCordinatesLink(Set<String> unitId)
    {
         system.debug('unitList future '+unitId);
        List<Unit__c> unitList = [SELECT Id,Name,Unit_Number__c, Type_of_Unit__c,Allow_this_unit__c,Unit_Location__c, Unit_Location__Latitude__s, Unit_Location__Longitude__s,Google_Coordinates_Link__c FROM Unit__c WHERE Id IN: unitId];
        Map<Id, String> unitMap = new Map<Id, String>();
        for(Unit__c unitrec:unitList){
            unitMap.put(unitrec.Id, unitrec.Google_Coordinates_Link__c);
        }
		List<Unit__c> unitsToUpdate = new List<Unit__c>();
        system.debug('future map :'+unitMap);
		for(Id unitsId :unitMap.KeySet()){
        Http http = new Http();
        
        HttpRequest request = new HttpRequest();
        
        String shortUrl = unitMap.get(unitsId);
        
        
        request.setEndpoint(shortUrl);
        
        request.setMethod('GET');
        
        request.setHeader('Content-Type', 'application/json');
        
        request.setHeader('Accept', '*/*');
        
        request.setTimeout(60000); // Set timeout as needed
        
        HttpResponse response;
        	if(!Test.isRunningTest()){
             response =http.send(request);
            } else{
               response = new HttpResponse();
    			response.setHeader('Location',
       			 'https://www.google.com/maps/place/MJ+Eye+care/@12.8634951,80.0746128,17.97z/data=!4m6!3m5!1s0x3a52f7b1718f8765:0x7eb29f453afe449f!8m2!3d12.8629364!4d80.0759706!16s%2Fg%2F11vr96r9s1'
    			);
    			response.setStatusCode(302);
            }
        String expandedUrl = shortUrl;
       system.debug('response 123: ' + response);
        if (response.getStatusCode() == 301 || response.getStatusCode() == 302 || response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            
            String locationHeader = response.getHeader('Location');
            system.debug('response 123 locationHeader: ' + locationHeader);
            if (locationHeader != null) {
                 List<String> parts = New List<String>();
                expandedUrl = locationHeader;
                
                request.setEndpoint(locationHeader);
                
                if(!Test.isRunningTest()){
                    response = http.send(request);
                    system.debug('response:85  ' + response);
                }
                
                System.debug('Expanded URL: ' + expandedUrl);
                String latPart ='';
                String lonPart = '';
                String fullUrl = expandedUrl;
                if (fullUrl.contains('!3d') && fullUrl.contains('!4d')) {
             latPart = fullUrl.substringAfter('!3d');
            latPart = latPart.substringBefore('!4d');
            
            lonPart = fullUrl.substringAfter('!4d');
            lonPart = lonPart.split('!')[0]; // In case there's more after !4d
            lonPart= lonPart.substringBefore('?');
                }
                // Extract the substring starting from the @ symbol
                String coordinatePart = expandedUrl.substringAfter('@');
                if(coordinatePart ==''){
                    coordinatePart = expandedUrl.substringAfter('search/').substringBefore('?');
                }
                if(coordinatePart == ''){
                     coordinatePart = expandedUrl.substringAfter('?q=').substringBefore('&');
                }
                System.debug('coordinatePart ' + coordinatePart);
                // The coordinates part is separated by a comma
                parts = coordinatePart.split(',');
                 System.debug('(parts.size() ' + parts);
                // The first part is latitude and the second part is longitude
                if (parts.size() >= 2 || (lonPart != '' && latPart != '')) {
                    try {
                        Unit__c newUnit = New Unit__c();
                        newUnit.Unit_Location__Latitude__s = latPart !=''? Decimal.valueOf(latPart):Decimal.valueOf(parts[0]);
                        newUnit.Unit_Location__Longitude__s = lonPart !=''? Decimal.valueOf(lonPart): Decimal.valueOf(parts[1]);
                        newUnit.id = unitsId;
                        unitsToUpdate.add(newUnit);
                        System.debug('unitId to update the unit ' + unitId);
                        
                    } catch (Exception e) {
                        System.debug('Error parsing coordinates: ' + e.getMessage());
                    }
                }
            }
            
        }
		}
		
		if(!unitsToUpdate.IsEmpty()){
			Update unitsToUpdate;
            UnitTriggerHandler.checkDuplicateNewUnit(unitList);
		}
        
    } 
    
}