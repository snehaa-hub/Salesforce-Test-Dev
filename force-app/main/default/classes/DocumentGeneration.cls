global class DocumentGeneration implements DocumentService{
    global String GenerateQuotePdf(String OpportunityID ,String Document) {
        try{
            Shortlisted_Unit__c shortlist = [
                SELECT Id, Opportunity__r.Property_Type__c,Opportunity__r.Share_Location__c , Opportunity__r.Landlord_Mobile__c ,Opportunity__r.Landlord_Name__c ,
                Unit__r.Type_of_Unit__c, Unit_Bundle__c 
                FROM Shortlisted_Unit__c 
                WHERE Opportunity__c = :OpportunityID LIMIT 1
            ];
            string contentTitle;
            String contentType;
            PageReference ref;
            if(shortlist !=null){
                if(Document ==''){
                    contentTitle ='Proposal';
                    System.debug('contentTitle' +contentTitle);
                }else{
                    contentTitle =Document;
                    System.debug('contentTitle' +contentTitle);
                }
                if(shortlist.Opportunity__r.Property_Type__c == 'Shed'){
                    ref = Page.QuotePdf;
                    if(
                       Boolean.valueOf(shortlist.Opportunity__r.Landlord_Mobile__c) ||
                       Boolean.valueOf(shortlist.Opportunity__r.Landlord_Name__c)){
                           contentType = 'Executive(Shed) Proposal';
                           System.debug('ref' +ref);
                       }else {
                           contentType = 'Tenant(Shed) Proposal';
                       }
                    
                    
                    System.debug('ref' +ref);
                }
                else if(shortlist.Opportunity__r.Property_Type__c == 'Land'){
                    ref = Page.LandProposal;
                    if(
                       Boolean.valueOf(shortlist.Opportunity__r.Landlord_Mobile__c) ||
                       Boolean.valueOf(shortlist.Opportunity__r.Landlord_Name__c)){
                           contentType = 'Executive(Land) Proposal';
                           System.debug('ref' +ref);
                       }else {
                           contentType = 'Tenant(Land) Proposal';
                       }
                    
                    System.debug('ref' +ref);
                }
                else if(shortlist.Opportunity__r.Property_Type__c == 'BTS'){
                    ref = Page.BTSProposal;
                    if(
                       Boolean.valueOf(shortlist.Opportunity__r.Landlord_Mobile__c) ||
                       Boolean.valueOf(shortlist.Opportunity__r.Landlord_Name__c)){
                           contentType = 'Executive(BTS) Proposal';
                           System.debug('ref' +ref);
                       }else  {
                           contentType = 'Tenant(BTS) Proposal';
                       }
                    
                    
                    System.debug('ref' +ref);
                }
                
            }
            
            
            if(ref != null){
                ref.getParameters().put('id',OpportunityID);
                //Set<Id> unitIdSet = New Set<Id>();
                Blob body;
                if(Test.isRunningTest()){
                    body = Blob.valueOf('Testing Documents');
                }
                else{
                    System.debug('inside else if body' +ref.getContent());
                    body = ref.getContent();
                    System.debug('inside else if body' +body);
                }
                Schema.DescribeFieldResult fieldResult = ContentVersion.Document_Type__c.getDescribe();
                Set<String> validPicklistValues = new Set<String>();
                for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                    validPicklistValues.add(entry.getValue());
                }
                contentType = contentType != null ? contentType.trim() : null;
                system.debug('body' + body);
                
                system.debug('72 contentTitle' + contentType);
            /*    Compression.ZipWriter writer = new Compression.ZipWriter();
        String pdfFileName = contentTitle + '.pdf';
        writer.addEntry(pdfFileName, body);
        Blob zipBlob = writer.getArchive();

        // Create the ZIP as a ContentVersion record
        ContentVersion zipCV = new ContentVersion();
        zipCV.ContentLocation = 'S';
        zipCV.PathOnClient = contentTitle + '.zip';
        zipCV.Title = contentTitle + '_Bundle';
        
        zipCV.VersionData = zipBlob;
        zipCV.FirstPublishLocationId = OpportunityID;
        zipCV.SObjectType__c = 'Opportunity__c';

        // Set picklist value if valid
        if (validPicklistValues.contains(contentType)) {
            zipCV.Document_Type__c = contentType;
        }

        insert zipCV;
        System.debug('ZIP ContentVersion inserted: ' + zipCV.Id);*/
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S';
                conVer.PathOnClient = contentTitle + '.pdf';
                conVer.Title = contentTitle +'.Pdf';  
                conVer.VersionData = body;
                conVer.FirstPublishLocationId = OpportunityID;
                conVer.SObjectType__c = 'Opportunity__c';
               // conVer.Document_Type__c =  contentTitle ;
                if (validPicklistValues.contains(contentType)) {
                    conVer.Document_Type__c = contentType;
                }
                INSERT conVer;
            }
            return ''; 
             }
            /*   if(unitbundle.Cost_Sheet_Generated__c == false){
unitbundle.Cost_Sheet_Generated__c = true;
}
UPDATE unitbundle;*/
       catch(Exception e){
            system.debug('msg ' +e.getMessage() + ' , lne' + e.getLineNumber());
            return e.getMessage();
        }
    }
    
    /*global void GenerateProposalForSiteOwner(String unitBundleId, String OpportunityID) {
system.debug('unitBundleId' + unitBundleId);
try{
/* Unit_Bundle__c unitbundle = [SELECT 
Id,
Name,
No_of_Cost_Sheet_Generated__c,
Cost_Sheet_Generated__c,
Opportunity__r.Project__c,
Opportunity__c
FROM Unit_Bundle__c
WHERE Id =: unitBundleId];

String noOfCostSheet;
if(unitbundle.No_of_Cost_Sheet_Generated__c == null){
noOfCostSheet = '1';
unitbundle.No_of_Cost_Sheet_Generated__c = 1;
}else{
noOfCostSheet = String.valueOf(unitbundle.No_of_Cost_Sheet_Generated__c);
unitbundle.No_of_Cost_Sheet_Generated__c += 1;
}*/
    
    /* PageReference ref = Page.QuotePdf;
ref.getParameters().put('id',unitBundleId);


//Set<Id> unitIdSet = New Set<Id>();
system.debug('unitBundleId'+unitBundleId);
Blob body;
if(Test.isRunningTest()){
body = Blob.valueOf('Testing Documents');
}
else{
body = ref.getContent();
}

system.debug('body' + body);

ContentVersion conVer = new ContentVersion();
conVer.ContentLocation = 'S';
conVer.PathOnClient = 'Quote' + '.pdf'; 
conVer.Title = 'Quote'  + '.pdf';  
conVer.VersionData = body;
conVer.FirstPublishLocationId = OpportunityID;
conVer.SObjectType__c = 'Opportunity';
conVer.Document_Type__c = 'Proposal Pdf';
INSERT conVer;

}catch(Exception e){

system.debug('msg ' +e.getMessage() + ' , lne' + e.getLineNumber());
}
}*/
    global void GenerateNegotiationChecklistPdf(String OpportunityID, String unitBundleId, String DocumentTittle) {
        try{
            Unit_Bundle__c unitbundle = [SELECT 
                                         Id,
                                         Name,
                                         Negotiation_Checklist__c,
                                         No_of_Negotiation_Checklist_Generated__c
                                         FROM Unit_Bundle__c
                                         WHERE Id =: unitBundleId];
            
            String noOfCostSheet;
            if(unitbundle.No_of_Negotiation_Checklist_Generated__c == null){
                noOfCostSheet = '1';
                unitbundle.No_of_Negotiation_Checklist_Generated__c = 1;
            }else{
                noOfCostSheet = String.valueOf(unitbundle.No_of_Negotiation_Checklist_Generated__c);
                unitbundle.No_of_Negotiation_Checklist_Generated__c += 1;
            }
            System.debug('Checklist BEFORE PDF creation: ' + unitBundle.Negotiation_Checklist__c);
            PageReference ref = Page.negotiationChecklistPDF;
            ref.getParameters().put('id',OpportunityID);
            ref.getParameters().put('unitBundleId',unitBundleId);
            
            Blob body;
            System.debug('above if body' +body);
            System.debug('Test.isRunningTest()' +Test.isRunningTest());
            if(Test.isRunningTest()){
                body = Blob.valueOf('Testing Documents');
                System.debug('INSIDE if body' +body);
            }
            else{
                body = ref.getContent();
                System.debug('INSIDE else if body' +body);
            }
            
            system.debug('body' + body);
            //conVer.Title = 'Options'+'('+ noOfCostSheet+ ')'+ '.pdf';
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = unitbundle.Name+'('+ noOfCostSheet+ ')'+ '.pdf'; 
            conVer.Title = DocumentTittle+ '.pdf';
            conVer.VersionData = body;
            conVer.FirstPublishLocationId = OpportunityID;
            conVer.SObjectType__c = 'Opportunity__c';
            conVer.Document_Type__c = 'Negotiation Checklist';
            INSERT conVer;
            UPDATE unitbundle;
        }catch(Exception e){
            
            system.debug('msg ' +e.getMessage() + ' , lne' + e.getLineNumber());
        }
    }
    
    global void GenerateSiteVisitQuotePdf(String unitBundleId, String OpportunityID, String siteVisitId){
        system.debug('unitBundleId 164' + unitBundleId);
        try{
            PageReference ref = Page.SiteVisitQuotePdf;
            ref.getParameters().put('id',unitBundleId);
            
            system.debug('unitBundleId'+unitBundleId);
            Blob body;
            if(Test.isRunningTest()){
                body = Blob.valueOf('Testing Site Visit Proposal Documents');
            }
            else{
                body = ref.getContent();
            }
            
            system.debug('body' + body);
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = 'Site Visit Proposal' + '.pdf'; 
            conVer.Title = 'Site Visit Proposal'  + '.pdf';  
            conVer.VersionData = body;
            conVer.FirstPublishLocationId = OpportunityID;
            conVer.SObjectType__c = 'Opportunity__c';
            conVer.Document_Type__c = 'Site Visit Proposal Pdf';
            //INSERT conVer;
            
            Site_Visit__c sv = [SELECT Id,Name,Owner.Email,Owner.Name,Account__c,
                                Opportunity__c,Unit_Bundle__c 
                                FROM Site_Visit__c WHERE Id=:siteVisitId];
            if(sv.OwnerId!=null){
                EmailTemplate emailTemplate = [select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Site_Visit_Proposal'];
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, sv.Id);
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                semail.setToAddresses(new List<String>{sv.Owner.Email});
                semail.setSubject(mail.getSubject());
                //semail.setHtmlBody(mail.getHtmlValue());
                semail.setPlainTextBody(mail.getPlainTextBody());
                semail.setSaveAsActivity(true);
                
                semail.setEntityAttachments(new List<String>{conVer.Id});
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { semail });
            }
            
        }
        catch(Exception e){
            
            system.debug('msg ' +e.getMessage() + ' , line' + e.getLineNumber());
        }
    }
    
    global void GenerateSiteVisitInspectionpdf(string OpportunityID, String siteVisitId){
        
        try{
            PageReference ref = Page.SiteVisitInspectionChecklistPdf;
            ref.getParameters().put('Id',siteVisitId);
            
            
            Blob body;
            if(Test.isRunningTest()){
                body = Blob.valueOf('Testing Site Visit Inspection Documents');
            }
            else{
                body = ref.getContent();
            }
            
            system.debug('body' + body);
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = 'FeedBack Form' + '.pdf'; 
            conVer.Title = 'FeedBack Form'  + '.pdf';  
            conVer.VersionData = body;
            conVer.FirstPublishLocationId = OpportunityID;
            conVer.SObjectType__c = 'Opportunity__c';
            conVer.Document_Type__c = 'FeedBack Form Pdf';
            // INSERT conVer;
            
            Site_Visit__c sv = [SELECT Id,Name,Owner.Email,Owner.Name,Account__c,
                                Opportunity__c,Unit_Bundle__c 
                                FROM Site_Visit__c WHERE Id=:siteVisitId];
            if(sv.OwnerId!=null){
                EmailTemplate emailTemplate = [select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Site_Visit_Proposal'];
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, sv.Id);
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                semail.setToAddresses(new List<String>{sv.Owner.Email});
                semail.setSubject(mail.getSubject());
                //semail.setHtmlBody(mail.getHtmlValue());
                semail.setPlainTextBody(mail.getPlainTextBody());
                semail.setSaveAsActivity(true);
                
                semail.setEntityAttachments(new List<String>{conVer.Id});
                // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { semail });
            }
            
        }
        catch(Exception e){
            
            system.debug('msg ' +e.getMessage() + ' , line' + e.getLineNumber());
        }
    }
}