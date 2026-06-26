/**
* @description This class to used convert lead record into enquiry record 
*/
public without sharing class ConvertLeadToEnquiry {
    
    /**
* @description This invocable method to used convert lead record into enquiry record 
* @param requestList
*/
    @InvocableMethod(label='Convert Lead To Enquiry' description='Convert Lead To Enquiry')
    public static void execute(List<Request> requestList) {
        if (!requestList.isEmpty()) {
            List<Lead> leadList = new List<Lead>();
            List<Lead> leadListToBeUpdated = new List<Lead>();
            Map<Id,Enquiry__c> leadEnquiryMap = new Map<Id,Enquiry__c>();
            
            for (Request req : requestList) {
                leadList.add(req.leadRecord);
            }
            
            Map<String, Lead_Conversion_Mapping__mdt> leadConversionMappingMap = Lead_Conversion_Mapping__mdt.getAll();
            System.debug('leadConversionMappingMap : ' +leadConversionMappingMap);
            if (!leadConversionMappingMap.isEmpty()) {
                
                Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                    .get(System.Label.Person_Account_RecordType_Name)
                    .getRecordTypeId();
                
                Id sellerEnquiryId = Schema.SObjectType.Enquiry__c.getRecordTypeInfosByName()
                    .get(System.Label.Enquiry_Seller_Record_Type_Name)
                    .getRecordTypeId();
                
                Id buyerEnquiryId = Schema.SObjectType.Enquiry__c.getRecordTypeInfosByName()
                    .get(System.Label.Enquiry_Buyer_Record_Type_Name)
                    .getRecordTypeId();
                
                List<Account> accountList = new List<Account>();
                List<Enquiry__c> enquiryList = new List<Enquiry__c>();
                
                for (Lead ld : leadList) {
                    Map<String, Object> leadMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(ld));
                    Account accountObj = new Account();
                    Enquiry__c enquiry = new Enquiry__c();
                    accountObj.RecordTypeID = personAccountId;
                    for (String nameleadMapping : leadConversionMappingMap.keySet()) {
                        if (leadConversionMappingMap.get(nameleadMapping).SObject__c == 'Account') {
                            accountObj.put(
                                leadConversionMappingMap.get(nameleadMapping).Field_Api_Name__c,
                                leadMap.get(leadConversionMappingMap.get(nameleadMapping).Lead_Field_Api_Name__c)
                            );
                        }
                        else if (leadConversionMappingMap.get(nameleadMapping).SObject__c == 'Enquiry__c') {
                            if(leadConversionMappingMap.get(nameleadMapping).Field_Api_Name__c == 'RecordTypeId')
                            {
                                if(leadMap.get(leadConversionMappingMap.get(nameleadMapping).Lead_Field_Api_Name__c) == System.Label.Enquiry_Seller_Record_Type_Name){
                                    enquiry.RecordTypeId = sellerEnquiryId ;
                                }
                                else 
                                {
                                    enquiry.RecordTypeId = buyerEnquiryId ;
                                }
                            }
                            else
                            {
                                enquiry.put(
                                    leadConversionMappingMap.get(nameleadMapping).Field_Api_Name__c,
                                    leadMap.get(leadConversionMappingMap.get(nameleadMapping).Lead_Field_Api_Name__c)
                                );
                            }
                            
                        }
                    }
                    accountList.add(accountObj);
                    
                    enquiryList.add(enquiry);
                   
                    leadEnquiryMap.put(ld.Id,enquiry);
                }
                
                List<Enquiry__c> enquiryToBeInserted = new List<Enquiry__c>();
                enquiryToBeInserted = EnquiryService.searchAccountAndLinkEnquiry(accountList, enquiryList);
                
                if (!enquiryToBeInserted.isEmpty()) {
                    Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Enquiry__c;
                    Boolean thisUserMayUpdate = drSObj.isCreateable();
                    SObjectAccessDecision securityDecision = Security.stripInaccessible(
                        AccessType.CREATABLE,  enquiryToBeInserted);
                    if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
                        insert securityDecision.getRecords();
                    }
                }
                
                // To populate the Id of Account and Enquiry on Lead.
                if(leadEnquiryMap != null){
                    for(Id leadId:leadEnquiryMap.keyset()){
                        if(leadEnquiryMap.get(leadId).Contact_Person__c!= null){
                            
                            Lead lead = new Lead(Id = leadId);
                            lead.Enquiry__c = leadEnquiryMap.get(lead.Id).Id;
                            lead.Account__c = leadEnquiryMap.get(lead.Id).Contact_Person__c;
                            leadListToBeUpdated.add(lead);
                        }
                        if(!leadListToBeUpdated.isEmpty()){
                            Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Lead;
                            Boolean thisUserMayUpdate = drSObj.isUpdateable();
                            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                AccessType.UPDATABLE,  leadListToBeUpdated);
                            
                            if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
                                update securityDecision.getRecords();
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
* @description This is request wrapper
*/
    public class Request {
        @InvocableVariable(label='Lead Record' required=true)
        public Lead leadRecord;
    }
}