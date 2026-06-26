global class CreatePersonAccountsBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Modify the WHERE clause to suit your needs
        return Database.getQueryLocator([
            SELECT Id, Name, Mobile__c, Email__c
            FROM Enquiry__c
            WHERE Contact_Person__c = NULL
        ]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Enquiry__c> enquiries = (List<Enquiry__c>) scope;
        List<Account> accountsToInsert = new List<Account>();
        Map<String, Id> enquiryMap = new Map<String, Id>();

        Id personAccountRTId = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Account' 
            AND Name = 'Person Account' 
            LIMIT 1
        ].Id;

        for (Enquiry__c enq : enquiries) {
            if (enq.Name != null && enq.Mobile__c != null && enq.Email__c != null) {
                Account acc = new Account();
                acc.LastName = enq.Name;
                acc.Phone = enq.Mobile__c;
                acc.Email__c = enq.Email__c;
                acc.RecordTypeId = personAccountRTId;
                

                String matchString = enq.Name + enq.Mobile__c + enq.Email__c;
                
                if(!enquiryMap.containsKey(matchString)){
                    enquiryMap.put(matchString, enq.Id);
                    accountsToInsert.add(acc);
                }
            }
        }

        if (!accountsToInsert.isEmpty()) {
            database.insert(accountsToInsert,false);
			System.debug('Account record Insert '+accountsToInsert);
            List<Enquiry__c> enquiriesToUpdate = new List<Enquiry__c>();
            for (Account acc : accountsToInsert) {
                String matchString = acc.LastName + acc.Phone + acc.Email__c;
                Id enqId = enquiryMap.get(matchString);
                if (enqId != null) {
                    enquiriesToUpdate.add(new Enquiry__c(
                        Id = enqId,
                        Contact_Person__c = acc.Id
                    ));
                }
            }
			System.debug('Enquiry record Update '+enquiriesToUpdate);
            if (!enquiriesToUpdate.isEmpty()) {
                database.update(enquiriesToUpdate,false);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: Send notification or log
    }
}