public class SiteVisitTriggerHandler {

    public static void processSiteVisits(List<Site_Visit__c> newList, Map<Id, Site_Visit__c> oldMap){

        List<Site_Visit__c> validRecords = new List<Site_Visit__c>();

        // Filter records (Insert + Update condition)
        for(Site_Visit__c sv : newList){

            // INSERT
            if(oldMap == null){
                if(sv.Resource_Allocator__c != null){
                    validRecords.add(sv);
                }
            }
            // UPDATE
            else{
                Site_Visit__c oldSv = oldMap.get(sv.Id);

                if(sv.Resource_Allocator__c != oldSv.Resource_Allocator__c && sv.Resource_Allocator__c != null){
                    validRecords.add(sv);
                }
            }
        }

        if(validRecords.isEmpty()) return;

        Set<Id> bundleIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();

        for(Site_Visit__c sv : validRecords){
            if(sv.Unit_Bundle__c != null){
                bundleIds.add(sv.Unit_Bundle__c);
            }
            userIds.add(sv.Resource_Allocator__c);
        }

        //Get Users
        Map<Id, User> userMap = new Map<Id, User>(
            [SELECT Id, Name, Email FROM User WHERE Id IN :userIds]
        );

        //Get Unit Bundles
        Map<Id, Unit_Bundle__c> bundleMap = new Map<Id, Unit_Bundle__c>(
            [SELECT Id, Linked_Unit__c FROM Unit_Bundle__c WHERE Id IN :bundleIds]
        );

        //Parse JSON → Shortlisted Unit IDs
        Set<Id> shortlistedUnitIds = new Set<Id>();

        for(Unit_Bundle__c bundle : bundleMap.values()){
            if(bundle.Linked_Unit__c != null){
                List<Object> ids = (List<Object>) JSON.deserializeUntyped(bundle.Linked_Unit__c);
                for(Object obj : ids){
                    shortlistedUnitIds.add((Id)obj);
                }
            }
        }

        if(shortlistedUnitIds.isEmpty()) return;

        //Get Shortlisted Units
        Map<Id, Shortlisted_Unit__c> shortlistedMap = new Map<Id, Shortlisted_Unit__c>(
            [SELECT Id, Unit__c FROM Shortlisted_Unit__c WHERE Id IN :shortlistedUnitIds]
        );

        //Get Unit IDs
        Set<Id> unitIds = new Set<Id>();

        for(Shortlisted_Unit__c su : shortlistedMap.values()){
            if(su.Unit__c != null){
                unitIds.add(su.Unit__c);
            }
        }

        if(unitIds.isEmpty()) return;

        //Get Unit Details         
        Map<Id, Unit__c> unitMap = new Map<Id, Unit__c>(
            [SELECT Id,
                    Point_of_Contact__r.Name,
                    Point_of_Contact__r.PersonEmail,
                    Point_of_Contact__r.PersonMobilePhone,
                    Google_Coordinates_Link__c
             FROM Unit__c
             WHERE Id IN :unitIds]
        );

        //Prepare Emails (ONE EMAIL PER SITE VISIT)
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Site_Visit__c sv : validRecords){

            if(!userMap.containsKey(sv.Resource_Allocator__c)) continue;

            String toEmail = userMap.get(sv.Resource_Allocator__c).Email;

            //Combine all unit details into one email
            String combinedBody = '';

            for(Unit__c unit : unitMap.values()){

                combinedBody += 'Landlord Name: ' + unit.Point_of_Contact__r.Name + '\n'
                              + 'Mobile: ' + unit.Point_of_Contact__r.PersonMobilePhone + '\n'
                              + 'Email: ' + unit.Point_of_Contact__r.PersonEmail + '\n'
                              + 'Location: ' + unit.Google_Coordinates_Link__c + '\n\n';
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new List<String>{toEmail});
            mail.setSubject('Site Visit Scheduled');

            String body = 'Dear ' + userMap.get(sv.Resource_Allocator__c).Name + ',\n\n'
                        + 'You have been assigned a Site Visit. Please find the details below:\n\n'
                        + combinedBody
                        + 'Site Visit Date & Time: ' + String.valueOf(sv.Visit_Date_Time__c) + '\n'
                        + 'No. of Persons Accompanying: ' + String.valueOf(sv.No_of_People_Planned__c) + '\n\n'
                        + 'Please proceed with the inspection accordingly.\n\n'
                        + 'Best Regards,\nTeam';

            mail.setPlainTextBody(body);

            emails.add(mail);
        }

       
        if(!emails.isEmpty() && !Test.isRunningTest()){
            Messaging.sendEmail(emails);
        }
    }
}