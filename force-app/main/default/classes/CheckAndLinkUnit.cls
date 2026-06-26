/**
 * @description This class is used to check and link unit with unit bundle
 */
public without sharing class CheckAndLinkUnit {
    
    /**
     * @description This invocable method is used to check and link unit with unit bundle
     * @param requestLst
     * @return list of string(If any error)
     */
	@InvocableMethod(label='Check And Link Unit' description='Check And Link Unit With Unit Bundle')
	public static List<String> execute(List<Request> requestLst){
        system.debug('13 requestLst: ' + requestLst);
        system.debug('13');
        List<String> errorList = new List<String>();
        if(!requestLst.isEmpty()){
              system.debug('16');
            
            List<Unit_Bundle__c> unitBundleList = new List<Unit_Bundle__c>();
            for(Request req : requestLst){
                Map<String, Object> unitBundleMap = new Map<String, Object>();
 				system.debug('17');
                system.debug('req.unitBundle---: '+req.unitBundle);
                if(req.unitBundle == null){
                    List<String> linkedUnits = new List<String>();
                    linkedUnits.add(req.shortListUnitId);
 					system.debug('18');
                    unitBundleMap.put('Opportunity__c',req.opportunityId);
                    unitBundleMap.put('Status__c',System.Label.Unit_Status_Shortlisted);
                    unitBundleMap.put('Name', 'Option - ' + (req.bundleNo + 1));
                    unitBundleMap.put('Linked_Unit__c',JSON.serialize(linkedUnits));
                    unitBundleMap.put('Tower_Block__c',req.towerId);
                    unitBundleMap.put('Number_Of_Base_Units__c',1);
					unitBundleMap.put('Is_OC_CC__c', req.isOCCC);
                    system.debug('17');
                    system.debug('Creating OpportunityWrapper...');
                    system.debug('opportunityId: ' + req.opportunityId);
                    system.debug('bundleNo: ' + req.bundleNo);

                    OpportunityWrapper oppWrap = new OpportunityWrapper();
                    oppWrap.Id = req.opportunityId;
                    oppWrap.unitBundleNo = req.bundleNo + 1;
                    // Integer bundleNoSafe = req.bundleNo != null ? req.bundleNo : 0;
                    // oppWrap.unitBundleNo = bundleNoSafe + 1;


                    // ConvertAndUpsertOpportunity.Request reqOpp = new ConvertAndUpsertOpportunity.Request();
                    // reqOpp.opportunityWrap = oppWrap;
                    // ConvertAndUpsertOpportunity.execute(new List<ConvertAndUpsertOpportunity.Request>{reqOpp});

                    ConvertAndUpsertOpportunity.Request reqOpp = new ConvertAndUpsertOpportunity.Request();
                    reqOpp.opportunityWrap = oppWrap;
                    ConvertAndUpsertOpportunity.execute(new List<ConvertAndUpsertOpportunity.Request>{reqOpp});
                    // ConvertAndUpsertOpportunity.Request reqOpp = new ConvertAndUpsertOpportunity.Request();
                    // reqOpp.opportunityWrap = oppWrap;
                    // oppRequests.add(reqOpp);
                }else{
                    system.debug('42');
                    List<String> linkedUnits = (List<String>) (JSON.deserialize(req.unitBundle.Linked_Unit__c, List<String>.class));
                    if(!linkedUnits.isEmpty()){
                         system.debug('45');
                        Boolean containsUnit = false;
                        for(String linkedUnit: linkedUnits){
                            if(req.shortListUnitId == linkedUnit){
                                containsUnit = true;
                            }
                        }
                         system.debug('52');
                        if(containsUnit == false){
                            linkedUnits.add(req.shortListUnitId);
                        }else{
                            errorList.add(System.Label.Error_Message_Unit_exists_in_Unit_Bundle);
                        }
                    }

                    unitBundleMap.put('Id',req.unitBundle.Id);
                    unitBundleMap.put('Linked_Unit__c',JSON.serialize(linkedUnits));
                    
                    if(req.unitType != System.Label.Unit_Category_Parking){
                         system.debug('64');
                        unitBundleMap.put('Number_Of_Base_Units__c', (req.unitBundle.Number_Of_Base_Units__c + 1)) ;
                        unitBundleMap.put('Booking_Line_Item__c','');
                        unitBundleMap.put('Payment_Milestones__c','');
                        unitBundleMap.put('Price_Details__c','');
                        unitBundleMap.put('Unit_UOM__c','');
                        unitBundleMap.put('Total_Area__c',null);
                        unitBundleMap.put('Total_Cost__c',null);
                        unitBundleMap.put('Pricing_Plan__c',null);
                        unitBundleMap.put('Payment_Plan__c',null);
                        unitBundleMap.put('Cost_Sheet_Generated__c',false);
                    }
                }

                Unit_Bundle__c unitBundle = (Unit_Bundle__c) JSON.deserialize(
                    JSON.serialize(unitBundleMap), 
                    Unit_Bundle__c.class
                );
				system.debug('unitBundleMap'+unitBundleMap);
                unitBundleList.add(unitBundle);
        	}
            // if (!oppRequests.isEmpty()) {
            //     ConvertAndUpsertOpportunity.execute(oppRequests);
            // }
            if(!unitBundleList.isEmpty()){
                SObjectAccessDecision securityDecision = Security.stripInaccessible(
                    AccessType.UPSERTABLE,  unitBundleList);
    
                if(!(securityDecision.getRecords()).isEmpty()){
                    upsert securityDecision.getRecords();
                }
            }
        }
        return errorList;
    }
    @AuraEnabled(cacheable=true)
    public static Integer getLastBundleNumber(String opportunityId) {
        List<Unit_Bundle__c> bundles = [
            SELECT Id FROM Unit_Bundle__c 
            WHERE Opportunity__c = :opportunityId
        ];
        return bundles.size() > 0 ? bundles.size() : 0;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> executeFromLWC(List<Request> requestLst) {
        return execute(requestLst);
    }
    /**
     * @description This is request wrapper
     */
    public class Request{
		@InvocableVariable(label = 'OpportunityId' description = 'Id of Opportunity' required = true)
		public String opportunityId;
        
        @InvocableVariable(label = 'ShortListUnitId' description = 'Id of ShortList Unit' required = true)
		public String shortListUnitId;
        
        @InvocableVariable(label = 'unitBundle' description = 'Unit Bundle Record' required = false)
		public Unit_Bundle__c unitBundle;
        
        @InvocableVariable(label = 'BundleNo' description = 'Bundle No' required = true)
		public Integer bundleNo;
        
        @InvocableVariable(label = 'Tower Id' description = 'Tower Id' required = false)
		public String towerId;
        
        @InvocableVariable(label = 'Unit Type' description = 'Unit Type' required = true)
		public String unitType;
        
        @InvocableVariable(label = 'Is OC/CC' description = 'Is OC/CC' required = false)
		public Boolean isOCCC;
	}
}