public with sharing class GetUnitController {

    @AuraEnabled(cacheable=true)
    public static List<Interested_Locations__c> getInterestedLocations(String recordId) {

        String enquiryId = null;
        try {
            List<Opportunity> oppList = [
                SELECT Id, Enquiry__c FROM Opportunity WHERE Id = :recordId LIMIT 1
            ];
            if (!oppList.isEmpty() && oppList[0].Enquiry__c != null) {
                enquiryId = oppList[0].Enquiry__c;
            }
        } catch (Exception e) {
            System.debug('Error fetching Opportunity Enquiry__c: ' + e.getMessage());
        }

        List<Interested_Locations__c> locations;
        if (enquiryId != null) {
            locations = [
                SELECT Id, Name, Address__City__s, Address__CountryCode__s,
                       Address__Latitude__s, Address__Longitude__s,
                       Address__Street__s, Address__StateCode__s
                FROM Interested_Locations__c
                WHERE Related_Opportunity__c = :recordId
                   OR Related_Enquiry__c     = :enquiryId
            ];
        } else {
            locations = [
                SELECT Id, Name, Address__City__s, Address__CountryCode__s,
                       Address__Latitude__s, Address__Longitude__s,
                       Address__Street__s, Address__StateCode__s
                FROM Interested_Locations__c
                WHERE Related_Opportunity__c = :recordId
            ];
        }

        Map<Id, Interested_Locations__c> seen = new Map<Id, Interested_Locations__c>();
        for (Interested_Locations__c loc : locations) {
            seen.put(loc.Id, loc);
        }
        List<Interested_Locations__c> uniqueLocations = seen.values();

        Set<String> allCities = new Set<String>();
        for (Interested_Locations__c loc : uniqueLocations) {
            String cityVal = String.isNotBlank(loc.Name)
                ? loc.Name : loc.Address__City__s;
            if (String.isNotBlank(cityVal)) {
                allCities.add(cityVal.toLowerCase());
            }
        }

        Map<String, Unit__c> cityToUnit = new Map<String, Unit__c>();
        if (!allCities.isEmpty()) {
            for (Unit__c u : [
                SELECT City__c, Unit_Location__Latitude__s, Unit_Location__Longitude__s
                FROM Unit__c
                WHERE Unit_Location__Latitude__s  != null
                  AND Unit_Location__Longitude__s != null
            ]) {
                if (u.City__c != null) {
                    String k = u.City__c.toLowerCase();
                    if (!cityToUnit.containsKey(k)) {
                        cityToUnit.put(k, u);
                    }
                }
            }
        }

        for (Interested_Locations__c loc : uniqueLocations) {
            String cityVal = String.isNotBlank(loc.Name)
                ? loc.Name : loc.Address__City__s;
            if (String.isNotBlank(cityVal)) {
                String cityKey = cityVal.toLowerCase();
                Unit__c refUnit = cityToUnit.get(cityKey);

                if (refUnit != null) {
                    loc.Address__Latitude__s  = refUnit.Unit_Location__Latitude__s;
                    loc.Address__Longitude__s = refUnit.Unit_Location__Longitude__s;
                } else {
                    loc.Address__Latitude__s  = null;
                    loc.Address__Longitude__s = null;
                }
            }
        }

        return uniqueLocations;
    }

    @AuraEnabled
    public static List<Unit__c> getInterestedLocationsUnit(String selectedBudgetType,
                                                           String typeOfUnit,
                                                           String unitCategory,
                                                           String eotCrane,
                                                           Double maxArea,
                                                           Double minArea,
                                                           Decimal latitude,
                                                           Decimal longitude,
                                                           Decimal radius,
                                                           List<Object> interestedLocation) {
        Set<Unit__c> unitsWithinRadius = new Set<Unit__c>();
        List<Map<String, Object>> locationMaps = new List<Map<String, Object>>();

        if (interestedLocation != null && !interestedLocation.isEmpty()) {
            for (Object obj : interestedLocation) {
                Map<String, Object> mapObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                locationMaps.add(mapObj);
            }
        }

        String query = 'SELECT Id, Name, Power_available__c, Type_of_Unit__c, City__c, ' +
            'Country__c, Postal_Code__c, Saleable_Area__c, State__c, Street__c, ' +
            'Unit_Status__c, Date_Available__c, Unit_Number__c, ' +
            'Unit_Location__Latitude__s, Unit_Location__Longitude__s, ' +
            'Budget__c, Contact_Number__c, Unit_Category__c, EoT_Crane_Provision__c ' +
            'FROM Unit__c WHERE Unit_Location__Longitude__s != null ' +
            'AND Unit_Location__Latitude__s != null';

        if (selectedBudgetType != null && selectedBudgetType != '' && selectedBudgetType != 'undefined') {
            query += ' AND Budget__c = :selectedBudgetType';
        }
        if (unitCategory != null && unitCategory != '' && unitCategory != 'undefined') {
            query += ' AND Unit_Category__c = :unitCategory';
        }
        if (eotCrane != null && eotCrane != '' && eotCrane != 'undefined') {
            query += ' AND EoT_Crane_Provision__c = :eotCrane';
        }
        if (typeOfUnit != null && typeOfUnit != '' && typeOfUnit != 'undefined') {
            query += ' AND Type_of_Unit__c = :typeOfUnit';
        }
        if (minArea > 0) {
            query += ' AND Saleable_Area__c >= :minArea';
        }
        if (maxArea > 0) {
            query += ' AND Saleable_Area__c <= :maxArea';
        }

        List<Unit__c> unitFilterList = Database.query(query);
        System.debug('Total units after filter: ' + unitFilterList.size());

        if (radius == null || radius <= 0) {
            return new List<Unit__c>();
        }

        Double radiusInDouble = radius.doubleValue();

        // Collect ALL auto-location city names unconditionally
        Set<String> citiesNeedingLookup = new Set<String>();
        for (Map<String, Object> mapObj : locationMaps) {
            if (!mapObj.containsKey('location')) continue;
            if (!(mapObj.get('location') instanceof Map<String, Object>)) continue;
            Map<String, Object> lm = (Map<String, Object>) mapObj.get('location');
            Object pv = lm.get('interestedLocaltionsPermanent');
            Boolean isPerm = (pv instanceof Boolean) ? (Boolean) pv : String.valueOf(pv) == 'true';
            if (!isPerm) continue;

            String cn = null;
            if (lm.containsKey('City') && lm.get('City') != null) {
                String v = String.valueOf(lm.get('City')).trim();
                if (String.isNotBlank(v)) cn = v;
            }
            if (cn == null && lm.containsKey('LocationName') && lm.get('LocationName') != null) {
                String v = String.valueOf(lm.get('LocationName')).trim();
                if (String.isNotBlank(v)) cn = v;
            }
            if (String.isNotBlank(cn)) citiesNeedingLookup.add(cn);
        }
        System.debug('citiesNeedingLookup: ' + citiesNeedingLookup);

        // Use SOQL IN clause to match city names — SOQL is case-insensitive so
        // "avadi" in the set matches "Avadi" or "AVADI" in City__c on the unit.
        // Store results with lowercase keys so the later lookup never fails on
        // case differences between what JS sent and what is stored on the unit.
        // ──────────────────────────────────────────────────────────────────────
        Map<String, Double[]> cityCoords = new Map<String, Double[]>();
        if (!citiesNeedingLookup.isEmpty()) {
            for (Unit__c u : [
                SELECT City__c, Unit_Location__Latitude__s, Unit_Location__Longitude__s
                FROM Unit__c
                WHERE City__c IN :citiesNeedingLookup
                  AND Unit_Location__Latitude__s  != null
                  AND Unit_Location__Longitude__s != null
            ]) {
                if (u.City__c == null) continue;
                String key = u.City__c.toLowerCase();
                if (!cityCoords.containsKey(key)) {
                    cityCoords.put(key, new Double[]{
                        u.Unit_Location__Latitude__s.doubleValue(),
                        u.Unit_Location__Longitude__s.doubleValue()
                    });
                }
            }
        }
        System.debug('cityCoords keys: ' + cityCoords.keySet());

        for (Map<String, Object> mapObj : locationMaps) {
            if (!mapObj.containsKey('location')) continue;
            if (!(mapObj.get('location') instanceof Map<String, Object>)) continue;
            Map<String, Object> locationMap = (Map<String, Object>) mapObj.get('location');

            Object permVal = locationMap.get('interestedLocaltionsPermanent');
            Boolean isPermanent = (permVal instanceof Boolean)
                ? (Boolean) permVal
                : String.valueOf(permVal) == 'true';

            Double centerLat = (locationMap.containsKey('Latitude')  && locationMap.get('Latitude')  != null) ? (Double) locationMap.get('Latitude')  : null;
            Double centerLng = (locationMap.containsKey('Longitude') && locationMap.get('Longitude') != null) ? (Double) locationMap.get('Longitude') : null;

            System.debug('isPermanent: ' + isPermanent + ' centerLat: ' + centerLat + ' city: ' + locationMap.get('City'));

            if (!isPermanent) {
                // MANUAL: Google geocoded coordinates
                if (centerLat != null && centerLng != null) {
                    for (Unit__c unit : unitFilterList) {
                        Double dist = Location.getDistance(
                            Location.newInstance(centerLat, centerLng),
                            Location.newInstance(unit.Unit_Location__Latitude__s.doubleValue(), unit.Unit_Location__Longitude__s.doubleValue()),
                            'Km'
                        );
                        if (dist <= radiusInDouble) unitsWithinRadius.add(unit);
                    }
                }
            } else {
                // AUTO: resolve center coordinates in priority order
                Double refLat = null;
                Double refLng = null;

                // Priority 1: SearchLat/SearchLng passed from JS
                if (locationMap.containsKey('SearchLat') && locationMap.get('SearchLat') != null) {
                    refLat = (Double) locationMap.get('SearchLat');
                    refLng = (Double) locationMap.get('SearchLng');
                    System.debug('AUTO → SearchLat: ' + refLat);
                }

                // Priority 2: city name lookup via SOQL-matched cityCoords (lowercase key)
                if (refLat == null || refLng == null) {
                    String cityName = null;
                    if (locationMap.containsKey('City') && locationMap.get('City') != null) {
                        String v = String.valueOf(locationMap.get('City')).trim();
                        if (String.isNotBlank(v)) cityName = v;
                    }
                    if (cityName == null && locationMap.containsKey('LocationName') && locationMap.get('LocationName') != null) {
                        String v = String.valueOf(locationMap.get('LocationName')).trim();
                        if (String.isNotBlank(v)) cityName = v;
                    }
                    if (String.isNotBlank(cityName)) {
                        String key = cityName.toLowerCase();
                        if (cityCoords.containsKey(key)) {
                            refLat = cityCoords.get(key)[0];
                            refLng = cityCoords.get(key)[1];
                            System.debug('AUTO → cityCoords[' + cityName + ']: ' + refLat);
                        }
                    }
                }

                if (refLat != null && refLng != null) {
                    for (Unit__c unit : unitFilterList) {
                        Double dist = Location.getDistance(
                            Location.newInstance(refLat, refLng),
                            Location.newInstance(unit.Unit_Location__Latitude__s.doubleValue(), unit.Unit_Location__Longitude__s.doubleValue()),
                            'Km'
                        );
                        if (dist <= radiusInDouble) unitsWithinRadius.add(unit);
                    }
                } else {
                    System.debug('AUTO: no coordinates resolved — city not matched in Unit__c.City__c');
                }
            }
        }

        System.debug('Units within radius: ' + unitsWithinRadius.size());
        return new List<Unit__c>(unitsWithinRadius);
    }

    @AuraEnabled
    public static List<Unit__c> getDataByUnitNumber(String unitNumber, String name, String typeUnit) {
        String searchKey = '%' + (unitNumber != null ? unitNumber.trim() : '') + '%';
        return [
            SELECT Id, Unit_Status__c, Contact_Number__c, Name, Power_available__c,
                   Date_Available__c, Budget__c, Saleable_Area__c, Unit_Category__c,
                   EoT_Crane_Provision__c, Type_of_Unit__c, Unit_Number__c
            FROM Unit__c
            WHERE (Unit_Number__c =: unitNumber OR Name =: name OR
                   Name LIKE :searchKey OR Unit_Number__c LIKE :searchKey)
              AND Type_of_Unit__c =: typeUnit
        ];
    }

    @AuraEnabled
    public static String getUnitId(String unitId, String oppId) {
        List<Shortlisted_Unit__c> shortList = [
            SELECT Id, Opportunity__c, Unit__c FROM Shortlisted_Unit__c
            WHERE Opportunity__c =: oppId AND Unit__c =: unitId LIMIT 1
        ];
        if (!shortList.isEmpty()) { return shortList[0].Unit__c; }
        return 'Success';
    }

    @AuraEnabled
    public static List<Unit__c> getUnitsByCrane(String category, String type) {
        if (String.isNotBlank(category) && String.isNotBlank(type)) {
            return [
                SELECT Id, Name, Unit_Category__c, Unit_Number__c, Unit_Status__c,
                       Contact_Number__c, Date_Available__c, Budget__c, Saleable_Area__c,
                       EoT_Crane_Provision__c, Type_of_Unit__c, Power_available__c
                FROM Unit__c
                WHERE Unit_Category__c = :category AND EoT_Crane_Provision__c = :type
            ];
        }
        return new List<Unit__c>();
    }
}