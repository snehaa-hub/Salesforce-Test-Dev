public without sharing class GetUnitDetails {

    public class RequestWrapper {
        @InvocableVariable(required=true)
        public Id siteVisitId;
    }

    public class ResponseWrapper {
        @InvocableVariable
        public Id unitId;
    }

    @InvocableMethod(label='Get Unit Details')
    public static List<ResponseWrapper> getUnitDetails(List<RequestWrapper> requests) {

        List<ResponseWrapper> responseList = new List<ResponseWrapper>();

        if(requests == null || requests.isEmpty()){
            return responseList;
        }

        Id siteVisitId = requests[0].siteVisitId;

        List<Site_Visit__c> siteVisits = [
            SELECT Id, Unit_Bundle__c
            FROM Site_Visit__c
            WHERE Id = :siteVisitId
            LIMIT 1
        ];
        system.debug('siteVisits'+siteVisits);

        if(siteVisits.isEmpty()){
            return responseList;
        }

        Set<Id> bundleIds = new Set<Id>();

        for(Site_Visit__c sv : siteVisits){
            if(sv.Unit_Bundle__c != null){
                bundleIds.add(sv.Unit_Bundle__c);
            }
        }
         system.debug('bundleIds'+bundleIds);

        if(bundleIds.isEmpty()){
            return responseList;
        }

        List<Unit_Bundle__c> bundles = [
            SELECT Id, Linked_Unit__c
            FROM Unit_Bundle__c
            WHERE Id IN :bundleIds
        ];

        Set<Id> shortlistedUnitIds = new Set<Id>();

        for(Unit_Bundle__c bundle : bundles){

            if(bundle.Linked_Unit__c != null){

                List<Object> ids =
                    (List<Object>)JSON.deserializeUntyped(
                        bundle.Linked_Unit__c
                    );

                for(Object obj : ids){
                    shortlistedUnitIds.add((Id)obj);
                }
            }
        }
        system.debug('shortlistedUnitIds'+shortlistedUnitIds);

        if(shortlistedUnitIds.isEmpty()){
            return responseList;
        }

        List<Shortlisted_Unit__c> shortlistedUnits = [
            SELECT Id, Unit__c
            FROM Shortlisted_Unit__c
            WHERE Id IN :shortlistedUnitIds
        ];

        for(Shortlisted_Unit__c su : shortlistedUnits){

            if(su.Unit__c != null){

                ResponseWrapper res = new ResponseWrapper();

                res.unitId = su.Unit__c;

                responseList.add(res);

                break;
                system.debug('res'+res);
            }
           
        }
       

        return responseList;
    }
    
}