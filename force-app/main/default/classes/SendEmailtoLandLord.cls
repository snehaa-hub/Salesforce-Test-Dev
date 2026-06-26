public class SendEmailtoLandLord {
    
    @InvocableMethod(label='SendEmailtoLandLord' description='Send Email to LandLord')
    public static void getUnitRecords(List<InputWrapper> input) {
        Set<String> UnitIds = new Set<String>();
        String visitDate = input[0].VisitDateTime;
        String unitbundles = input[0].UnitBundleId;
        
        //UnitBundleId = (List<UnitBundle>) JSON.deserialize(jsonData, List<UnitBundle>.class);
        List<Unit_Bundle__c> unitbundle = [SELECT Id,Linked_Unit__c FROM Unit_Bundle__c Where Id = : unitbundles  limit 1];
        
        if(!unitbundle.isEmpty() && String.isNotBlank(unitbundle[0].Linked_Unit__c)){
            List<String> ShortlistIds = (List<String>) JSON.deserialize(unitbundle[0].Linked_Unit__c , List<String>.class);
            List<Shortlisted_Unit__c> shortList = [SELECT Id,Unit__c FROM Shortlisted_Unit__c where Id in : ShortlistIds ];
            for(Shortlisted_Unit__c shortlistunit : shortList){
                UnitIds.add(shortlistunit.Unit__c);
            }
            
        }
        
       
        List<Unit__c> units = [SELECT Id, City__c,Point_of_Contact__r.PersonEmail , Date_Available__c, Name FROM Unit__c where Id in : UnitIds];
        system.debug('units :'+units.size());
        
        
        // List<Site_Visit__c> visits = 
        // [select id, Visit_Date_Time__c from Site_Visit__c  WHERE Id IN :siteVisitIds];
        // system.debug('visits : ' + visits.size());
         OrgWideEmailAddress owea = [
    SELECT Id
    FROM OrgWideEmailAddress
    WHERE Address = 'chennai@allwarehouses.in'
    LIMIT 1
];
        
        EmailTemplate  emails =  [SELECT Id,DeveloperName,Body,HtmlValue,Subject from EmailTemplate where DeveloperName  ='Template_for_Informing_about_Scheduling_Site_Visit_to_Landlord' Limit 1 ]; 
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Unit__c unit : units) {
            system.debug('unit :'+unit);
            system.debug('unit.Point_of_Contact__r.PersonEmail :'+unit.Point_of_Contact__r.PersonEmail);
            if(unit.Point_of_Contact__c != null && 
             String.isNotBlank(unit.Point_of_Contact__r.PersonEmail)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new list<string>{unit.Point_of_Contact__r.PersonEmail});
               // mail.setCcAddresses(new List<String>{ 'pooja@allwarehouses.in', 'chennai@allwarehouses.in' });
                mail.setCcAddresses(new List<String>{ 'chennai@allwarehouses.in' });
                 mail.setOrgWideEmailAddressId(owea.Id);
                string html = emails.HtmlValue.replace('#City',unit.City__c);
                
                string body =emails.Body.replace('#City',unit.City__c);
                String subject = emails.Subject;
                
                html = html.replace('#VisitDate', visitDate);
                body = body.replace('#VisitDate', visitDate);
                
                subject = subject.replace('#VisitDate',visitDate);
                mail.setHtmlBody(body);
                mail.setSubject(subject);
                mail.setPlainTextBody(html);
                // mail.setTargetObjectId(unit.Id);[$City] 
                // mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(true); 
                emailsToSend.add(mail);
            }
        }
        if (!emailsToSend.isEmpty()) {
            system.debug('emailsToSend : '+emailsToSend);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
            
        }
    }
    public class InputWrapper {
       // @InvocableVariable(required=true)
        //public List<String> UnitIds;
        
        @InvocableVariable
        public String VisitDateTime;
        @InvocableVariable
        public String UnitBundleId;
        
       
       
        
    }
    
}