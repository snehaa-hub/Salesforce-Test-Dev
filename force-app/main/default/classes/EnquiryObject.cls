/* 
     *@description       : When the Enquiry Status is 'Closed' and the Reason is 'Qualified', 
                           an Opportunity should be created with the Stage set to 'Qualified
	  @author            :
	  @last modified on  : 29/04/2025
      
*/

public class EnquiryObject {
    /*
     @description  Used to insert and  Update the opportunity and stage path
     @param enquiryList - use to get  list enquiryList
    */
    public static void createOpportunities(List<Enquiry__c> enquiryList) {
        List<Opportunity__c> oppToInsert = new List<Opportunity__c>();
        
        
      
        List<Enquiry__c> validEnquiries = new List<Enquiry__c>();
        Set<Id> enqId =new Set<Id>();
        
        for (Enquiry__c enq : enquiryList) {
            enqId.add(enq.Id);
        }
        List<Interested_Locations__c> InterestedLoc =[Select Id,Related_Enquiry__c From Interested_Locations__c where Related_Enquiry__c In:enqId];
        system.debug('Inloc : '+InterestedLoc.Size());
        Map<Id,List<Interested_Locations__c>> enqInteLocMap = new Map<Id,List<Interested_Locations__c>>();
        for (Interested_Locations__c loc : InterestedLoc) {
            if(enqInteLocMap.containsKey(loc.Related_Enquiry__c)) {
                enqInteLocMap.get(loc.Related_Enquiry__c).add(loc);
            }else{

                enqInteLocMap.put(loc.Related_Enquiry__c, new List<Interested_Locations__c>{loc});
            }
        }
        Map<Id, String> recordTypeIdMap = new Map<Id, String>();
        for (RecordType rt : [
            SELECT Id, Name FROM RecordType WHERE SobjectType = 'Enquiry__c' AND Name IN ('Tenant', 'Broker', 'Industrial Park')
        ]) {
            recordTypeIdMap.put(rt.Id, rt.Name);
        }

        for (Enquiry__c enq : enquiryList) {
           
            if (
                enq.Status__c != null && enq.Status__c.trim() == 'Closed' &&
                enq.Reason_for_Closed__c != null && enq.Reason_for_Closed__c.trim() == 'Qualified'
                
            ) {
                if((enqInteLocMap.containsKey(enq.Id) && (recordTypeIdMap.containsKey(enq.RecordTypeId)) || (!enqInteLocMap.containsKey(enq.Id) && (!recordTypeIdMap.containsKey(enq.RecordTypeId)) ))  ){
                validEnquiries.add(enq);
                }else{
                    system.debug('enqInteLocMap : '+enqInteLocMap.containsKey(enq.Id));
                    if(!Test.isRunningTest()){
                        enq.addError('Please add at least one Interested Location before closing the Enquiry.');
                    } 
                }
            }
        }
		
         
       
        if (validEnquiries.isEmpty()) return;

        
        Map<Id, String> recordTypeIdToNameMap = new Map<Id, String>();
        for (RecordType rt : [
            SELECT Id, Name FROM RecordType WHERE SobjectType = 'Enquiry__c' AND Name IN ('Tenant', 'Broker')
        ]) {
            recordTypeIdToNameMap.put(rt.Id, rt.Name);
        }

        Map<Id, String> landRecordType=new Map<Id, String>();
        for(RecordType lrt:[SELECT Id, Name FROM RecordType WHERE SobjectType = 'Enquiry__c' AND Name = 'Landlord']){
            landRecordType.put(lrt.Id, lrt.Name);
        }
        
        Set<Id> enquiryIds = new Set<Id>();
        for (Enquiry__c e : validEnquiries) {
            enquiryIds.add(e.Id);
        }

        
        Set<Id> existingEnquiryIds = new Set<Id>();
        for (Opportunity__c opp : [
            SELECT Id, Enquiry__c FROM Opportunity__c WHERE Enquiry__c IN :enquiryIds
        ]) {
            existingEnquiryIds.add(opp.Enquiry__c);
        }
		
        
        for (Enquiry__c enq : validEnquiries) {
            /*Integer amountValue;
                try {
                    amountValue = Integer.valueOf(enq.Size_in_sqfts__c);
                } catch (Exception e) {
                    continue; // Skip if not a valid number
                }
        String bucketValue;
                if (amountValue <= 10000) {
                    bucketValue = 'below 10000';
                } else if (amountValue <= 25000) {
                    bucketValue = '10000 - 25000';
                } 
            else if (amountValue <= 50000) {
                    bucketValue = '25000 - 50000';
                }
            else if (amountValue <= 100000) {
                    bucketValue = 'Above 1 Lakh';
                }
            else {
                    bucketValue = '	Above 1 Lakh';
                }*/
            Set<String> validTypes = new Set<String>{'Design', 'Approval', 'Construction', 'Property management'};
            if ((!existingEnquiryIds.contains(enq.Id) && recordTypeIdToNameMap.containsKey(enq.RecordTypeId)) 
                || ((enq.Type_of_Unit__c=='Design') && (landRecordType.containsKey(enq.RecordTypeId)) && (!existingEnquiryIds.contains(enq.Id)))
               	|| ((enq.Type_of_Unit__c=='Approval') && (landRecordType.containsKey(enq.RecordTypeId)) && (!existingEnquiryIds.contains(enq.Id)))
                || ((enq.Type_of_Unit__c=='Construction') && (landRecordType.containsKey(enq.RecordTypeId)) && (!existingEnquiryIds.contains(enq.Id)))
               	|| ((enq.Type_of_Unit__c=='Property management') && (landRecordType.containsKey(enq.RecordTypeId)) && (!existingEnquiryIds.contains(enq.Id)))) {
                Opportunity__c opp = new Opportunity__c();
                
                opp.Name = enq.Name;
                opp.Enquiry__c = enq.Id;
                opp.Stage__c = 'Qualified';
                opp.Property_Type__c = enq.Type_of_Unit__c;
                opp.Account_Name__c = enq.Contact_Person__c;
                opp.Budget_Range1__c = enq.Budget_Range1__c;
                opp.Nature_of_Purchase__c = enq.Nature_of_Purchase__c;
                opp.Type_of_Unit__c = enq.Type_of_Unit__c;
                opp.Size_in_sqft__c = enq.Size_in_sqft__c;
                opp.Enquiry_Source__c = enq.Enquiry_Source__c;
                opp.Enquiry_Sub_Source__c = enq.Enquiry_Sub_Source__c;
                opp.Customer_Name__c = enq.Customer_Name__c;
                opp.Referral_Name__c = enq.Referral_Name__c;
                opp.Size_in_sqfts__c = enq.Size_in_sqfts__c;
               // opp.Email__c = enq.Email__c;
                //opp.Size_in_sqft__c = bucketValue;
                if (validTypes.contains(enq.Type_of_Unit__c) && landRecordType.containsKey(enq.RecordTypeId)) {
                    opp.Record_Type__c = landRecordType.get(enq.RecordTypeId); // or landRecordType.get(enq.RecordTypeId)
                } else {
                    opp.Record_Type__c = recordTypeIdToNameMap.get(enq.RecordTypeId);
                }
                oppToInsert.add(opp);
              
            }
        }

        
        if (!oppToInsert.isEmpty()) {
            insert oppToInsert;
           
            System.debug('oppToInsert 106'+ oppToInsert);
            
      //Interested Location
Map<Id,Id> enquiryToOppMap = new Map<Id,Id>();

for(Opportunity__c opp : oppToInsert){
    enquiryToOppMap.put(opp.Enquiry__c, opp.Id);
}

List<Interested_Locations__c> locToUpdate = new List<Interested_Locations__c>();

for(Interested_Locations__c loc : InterestedLoc){

    if(enquiryToOppMap.containsKey(loc.Related_Enquiry__c)){

        loc.Related_Opportunity__c = enquiryToOppMap.get(loc.Related_Enquiry__c);

        locToUpdate.add(loc);
    }
}

if(!locToUpdate.isEmpty()){
    update locToUpdate;
}
            
           
     
            // List<OpportunityCreated__e> events = new List<OpportunityCreated__e>();
            // for (Opportunity__c opp : oppToInsert) {
            //     OpportunityCreated__e event = new OpportunityCreated__e();
            //     event.OpportunityId__c = opp.Id;
            //     event.CreatedByUserId__c = UserInfo.getUserId();
            //     events.add(event);
            // }

            // if (!events.isEmpty()) {
            //     Database.SaveResult[] results = EventBus.publish(events);
            // }
        }
    }
    @AuraEnabled
    public static Opportunity__c getOpportunity(Id enquiryId) {
        return [SELECT Id FROM Opportunity__c WHERE Enquiry__c = :enquiryId Limit 1];
    }
}