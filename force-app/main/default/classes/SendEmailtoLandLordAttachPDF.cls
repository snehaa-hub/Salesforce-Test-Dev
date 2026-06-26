public class SendEmailtoLandLordAttachPDF {
   /* @InvocableMethod(label='SendEmailtoLandLordAttachPdf' description='Send Email to LandLord Attach Pdf')
    public static void getUnitRecords(List<InputWrapper> input) {
        list<string> UnitIds = input[0].UnitIds;
        //String addresses = input[0].Address;
        
        List<Unit__c> units = [SELECT Id, City__c,Point_of_Contact__r.PersonEmail ,Address__c , Date_Available__c, Name FROM Unit__c where Id in : UnitIds];
        system.debug('units :'+units.size());
        
        
        // List<Site_Visit__c> visits = 
        // [select id, Visit_Date_Time__c from Site_Visit__c  WHERE Id IN :siteVisitIds];
        // system.debug('visits : ' + visits.size());
        
        
        EmailTemplate  emails =  [SELECT Id,DeveloperName,Body,HtmlValue,Subject from EmailTemplate where DeveloperName  ='Template_for_Site_Visit_Completed_Landlord_Along_with_this_you_should_attach' Limit 1 ]; 
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Unit__c unit : units) {
            system.debug('unit :'+unit);
            if(unit.Point_of_Contact__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.settoAddresses(new list<string>{unit.Point_of_Contact__r.PersonEmail});
                string html = emails.HtmlValue.replace('#City',unit.City__c);
               
                
                string body =emails.Body.replace('#City',unit.City__c);
                String subject = emails.Subject;
                
                html = html.replace('#Address', unit.Address__c);
                body = body.replace('#Address', unit.Address__c);
                
                subject = subject.replace('#City',unit.City__c);
                mail.setHtmlBody(body);
                mail.setSubject(subject);
                mail.setPlainTextBody(html);
                // mail.setTargetObjectId(unit.Id);[$City] 
                // mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(false); 
                emailsToSend.add(mail);
            }
        }
        if (!emailsToSend.isEmpty()) {
            system.debug('emailsToSend : '+emailsToSend);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
            
        }
    }
    public class InputWrapper {
        @InvocableVariable
        public List<String> UnitIds;
 
    }*/
    @InvocableMethod(label='SendEmailtoLandLordAttachPdf' description='Send Email to LandLord Attach Pdf')
public static void getUnitRecords(List<InputWrapper> input) {
    Set<String> UnitIds = new Set<String>();
    String SiteId = input[0].SiteIds;
    String unitbundles = input[0].UnitBundleId;
    System.debug('SiteId'+SiteId);
    
    List<Unit_Bundle__c> unitbundle = [SELECT Id,Linked_Unit__c FROM Unit_Bundle__c Where Id = : unitbundles  limit 1];
        
        if(!unitbundle.isEmpty()){
            List<String> ShortlistIds = (List<String>) JSON.deserialize(unitbundle[0].Linked_Unit__c , List<String>.class);
            List<Shortlisted_Unit__c> shortList = [SELECT Id,Unit__c FROM Shortlisted_Unit__c where Id in : ShortlistIds ];
            for(Shortlisted_Unit__c shortlistunit : shortList){
                UnitIds.add(shortlistunit.Unit__c);
            }
            
        }
    
    
    List<Unit__c> units = [SELECT Id, City__c, Point_of_Contact__r.PersonEmail, Address__c FROM Unit__c WHERE Id IN :UnitIds];
    Site_Visit__c  site   = [SELECT Id,Closed_Date__c FROM Site_Visit__c where Id =:SiteId limit 1];
    
    // Step 1: Generate PDFs
    List<Id> generatedDocIds = ImagePDFGenerator.generatePdfFromImages(SiteId);
	 System.debug('SiteId'+SiteId);
    // Step 2: Fetch PDF blobs
    List<ContentVersion> pdfVersions = [
        SELECT id, Title, VersionData, ContentDocumentId
        FROM ContentVersion
        WHERE id IN :generatedDocIds AND IsLatest = true
    ];
    Map<Id, ContentVersion> docIdToVersionMap = new Map<Id, ContentVersion>();
    for (ContentVersion ver : pdfVersions) {
        docIdToVersionMap.put(ver.id, ver);
    }

      OrgWideEmailAddress owea = [
    SELECT Id
    FROM OrgWideEmailAddress
    WHERE Address = 'chennai@allwarehouses.in'
    LIMIT 1
];
    EmailTemplate template = [SELECT Id, Body, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Template_for_Site_Visit_Completed_Landlord_Along_with_this_you_should_attach' LIMIT 1];
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

    Integer index = 0; // match PDF to unit by position if needed

    for (Unit__c unit : units) {
        if (unit.Point_of_Contact__r.PersonEmail != null) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{unit.Point_of_Contact__r.PersonEmail});
            mail.setCcAddresses(new List<String>{ 'chennai@allwarehouses.in' });
                 mail.setOrgWideEmailAddressId(owea.Id);
            
            String html = template.HtmlValue.replace('#City', unit.City__c).replace('#Address', unit.Address__c).replace('#Date' ,String.valueOf(site.Closed_Date__c));
            String body = template.Body.replace('#City', unit.City__c).replace('#Address', unit.Address__c).replace('#Date' ,String.valueOf(site.Closed_Date__c));
            String subject = template.Subject.replace('#City', unit.City__c);

            mail.setSubject(subject);
            mail.setPlainTextBody(html);
            mail.setHtmlBody(body);
            mail.setSaveAsActivity(false);

            // Attach PDF
            if (index < generatedDocIds.size()) {
                Id docId = generatedDocIds[index++];
                ContentVersion pdf = docIdToVersionMap.get(docId);
                if (pdf != null) {
                    system.debug('pdf.VersionData : '+pdf.VersionData);
                    system.debug('unit.Id : '+unit.Id);
                    system.debug('pdf.Title : '+pdf.Title);
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName(pdf.Title + '.pdf');
                    
                    attachment.setBody(pdf.VersionData);
                    attachment.setContentType('application/pdf');
                    mail.setFileAttachments(new  List<Messaging.EmailFileAttachment> { attachment });
                    system.debug('pdf.mail : '+mail);
                    System.debug('PDF Blob size (bytes): ' + pdf.VersionData.size());
                }
            }

            emailsToSend.add(mail);
        }
    }

    if (!emailsToSend.isEmpty()) {
        Messaging.sendEmail(emailsToSend);
    }
     
}
public class InputWrapper {
        @InvocableVariable
        public List<String> UnitIds;
       @InvocableVariable
    	public String SiteIds;
    @InvocableVariable
        public String UnitBundleId;
 
    }
}