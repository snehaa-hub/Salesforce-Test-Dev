public class negotiationChecklistController{
    public List<Wrapper> wrapList {get;set;}
    public String landlordName { get; set; }
    public String tenantName { get; set; }
    public String brokerName { get; set; }
    
    
    public negotiationChecklistController(){
        string unitBundleId;
        String oppId;
        unitBundleId = ApexPages.CurrentPage().getparameters().get('unitBundleId');
        oppId = ApexPages.CurrentPage().getParameters().get('opportunityId');
        
        System.debug('unitBundleId'+unitBundleId);
        String currentUserId = UserInfo.getUserId();
        if(unitBundleId!= null){

            List<Unit_Bundle__c> bundles = [SELECT Id, Name, Negotiation_Checklist__c, Opportunity__c, Linked_Unit__c  FROM Unit_Bundle__c 
                                            WHERE Id = :unitBundleId LIMIT 1];
            
            if (!bundles.isEmpty()) {

                Unit_Bundle__c unit = bundles[0];
                oppId = bundles[0].Opportunity__c;
                system.debug('oppId' +oppId);
                Opportunity__c  opplist = [SELECT Id,
                                            Account_Name__c,
                                            Account_Name__r.Name,
                                            Enquiry__c,
                                            Enquiry__r.RecordTypeId,
                                            Enquiry__r.RecordType.Name
                                            FROM Opportunity__c
                                            WHERE Id = :oppId
                                            LIMIT 1];
                if (opplist.Enquiry__r != null) {
        String rtName = opplist.Enquiry__r.RecordType.Name;
        if (rtName == 'Tenant') {
            tenantName = opplist.Account_Name__r.Name;
            brokerName = 'ALLWarehouses';
        } else if (rtName == 'Broker') {
            brokerName = opplist.Account_Name__r.Name;
        }
    }
                String shortListedUnitId;
                String jsonString = bundles[0].Linked_Unit__c;

                if (!String.isBlank(jsonString)) {
                    List<Object> idList = (List<Object>) JSON.deserializeUntyped(jsonString);
                    if (!idList.isEmpty()) {
                        shortListedUnitId = (String) idList[0];
                        System.debug('Extracted Id: ' + shortListedUnitId);
                    } else {
                        System.debug('JSON array was empty.');
                    }
                }

				List<Shortlisted_Unit__c> shotList = [SELECT Id, Opportunity__c, Unit__c
                          FROM Shortlisted_Unit__c 
                          WHERE Id = : shortListedUnitId];
                String unitId = shotList[0].Unit__c;
                Unit__c unitRecord = [
                SELECT Id, Point_of_Contact__c, Point_of_Contact__r.Name 
                FROM Unit__c 
                WHERE Id = :unitId
                ];

                landlordName = unitRecord.Point_of_Contact__r.Name;
                
                if(unit.Negotiation_Checklist__c != null && unit.Negotiation_Checklist__c != '')
                {
                    String cleanedJsonString = removeLeadingZeros(unit.Negotiation_Checklist__c);
                    wrapList = (List<Wrapper>) JSON.deserialize(cleanedJsonString, List<Wrapper>.class);
                    for(Wrapper wrap: wrapList){
                        if(wrap.IsMainHeading != 'true' && wrap.IsSubLabel == 'true'){
                            wrap.style = '';
                        }else {
                            wrap.style = 'Border : none !important';
                        }
                    }
                }
            }
            
            // if(unitBundle != null){
            
            //     //  for(Opportunity opp :opportunityList){
            //     System.debug('unitBundle.Negotiation_Checklist__c' +unitBundle.Negotiation_Checklist__c);
            //     if(unitBundle.Negotiation_Checklist__c != null && unitBundle.Negotiation_Checklist__c != '')
            //     {
            //         String cleanedJsonString = removeLeadingZeros(unitBundle.Negotiation_Checklist__c);
            //         System.debug('cleanedJsonString'+cleanedJsonString);
            //         wrapList = (List<Wrapper>) JSON.deserialize(cleanedJsonString, List<Wrapper>.class);
            //         system.debug('wrapList-------------------> '+ wrapList);
            //     }
            
            
            //     // }
            // }
        }
        
    }
    Public Class Wrapper{
        Public String Name{get;set;}
        Public String Value{get;set;}
        Public String SequenceNo{get;set;}
        Public String DefaultValue{get;set;}
        Public String AdditionalValue{get;set;}
        Public String IsMainHeading{get;set;}
        Public String IsHeading{get;set;}
        Public String IsSubLabel{get;set;}
        Public Integer colSpan {get;set;}
        Public Integer colSpan2{get;set;}
        Public String sequenceVisible{get;set;}
        Public String AdditionalVisible{get;set;}
        Public string style{get;set;}
        public String Disclaimer{get;set;}
        public String Location{get;set;}
        /*Public Boolean Aplicant2{get;set;}
Public Boolean Aplicant3{get;set;}*/
    }
    private static String removeLeadingZeros(String jsonString) {
        // Regular expression to match numeric values with leading zeros
        String pattern = '(?<=[:\\[,\\s])0+(\\d+)';
        // Replace leading zeros with the actual number
        jsonString = jsonString.replaceAll(pattern, '$1');
        return jsonString;
    }
}