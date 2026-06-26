public with sharing class FeedbackInspectionController {
    
    public class Wrapper {
        @AuraEnabled public String landlordName;
        @AuraEnabled public String location;
        @AuraEnabled public String size;
        @AuraEnabled public Decimal chargeableArea;
        @AuraEnabled public Decimal rentPerSqFt;
    }
    
    @AuraEnabled(cacheable=true)
    public static Wrapper getUnitDetails(Id siteVisitId) {
        
        System.debug('=== Feedback Form Start ===');
        System.debug('Site Visit Id : ' + siteVisitId);
        
        Wrapper w = new Wrapper();
        
        try {
            
            if(siteVisitId == null){
                throw new AuraHandledException('Site Visit Id is missing.');
            }
            
            List<Site_Visit__c> siteVisitList = [SELECT Id, Unit_Bundle__c FROM Site_Visit__c WHERE Id = :siteVisitId LIMIT 1];
            
            if(siteVisitList.isEmpty()){
                throw new AuraHandledException('Site Visit record not found.');
            }
            
            Site_Visit__c sv = siteVisitList[0];
            
            System.debug('Unit Bundle Id : ' + sv.Unit_Bundle__c);
            if(sv.Unit_Bundle__c == null){
                throw new AuraHandledException('Unit Bundle is not available on Site Visit.');
            }
            
            List<Unit_Bundle__c> bundleList = [SELECT Id, Linked_Unit__c FROM Unit_Bundle__c WHERE Id = :sv.Unit_Bundle__c LIMIT 1];
            
            if(bundleList.isEmpty()){
                throw new AuraHandledException('Unit Bundle record not found.');
            }
            
            Unit_Bundle__c ub = bundleList[0];
            
            System.debug('Linked Unit JSON : ' + ub.Linked_Unit__c);
            
            if(String.isBlank(ub.Linked_Unit__c)){
                throw new AuraHandledException('Linked Unit JSON is empty.');
            }
            
            List<Object> ids = (List<Object>)JSON.deserializeUntyped(ub.Linked_Unit__c);
            
            if(ids == null || ids.isEmpty()){
                throw new AuraHandledException('No Unit found inside Linked Unit JSON.');
            }
            
            Id shortlistedUnitId = (Id)ids[0];
            
            System.debug('Shortlisted Unit Id : ' + shortlistedUnitId);
            
            List<Shortlisted_Unit__c> shortlistedUnits = [SELECT Id, Unit__c FROM Shortlisted_Unit__c WHERE Id = :shortlistedUnitId LIMIT 1];
            
            if(shortlistedUnits.isEmpty()){
                throw new AuraHandledException('Shortlisted Unit record not found.');
            }
            
            if(shortlistedUnits[0].Unit__c == null){
                throw new AuraHandledException('Unit lookup is blank on Shortlisted Unit.');
            }
            
            Id unitId = shortlistedUnits[0].Unit__c;
            
            System.debug('Actual Unit Id : ' + unitId);
            
            List<Unit__c> unitList = [SELECT Id, Point_of_Contact__r.Name, City__c, Size_Range__c, Saleable_Area__c, Rent_per_uom_Price_per_uom__c
                                      FROM Unit__c
                                      WHERE Id = :unitId
                                      LIMIT 1];
            
            if(unitList.isEmpty()){
                throw new AuraHandledException('Unit record not found.');
            }
            
            Unit__c unitRec = unitList[0];
            
            w.landlordName   = unitRec.Point_of_Contact__r != null ? unitRec.Point_of_Contact__r.Name : '';
            w.location       = unitRec.City__c;
            w.size           = unitRec.Size_Range__c;
            w.chargeableArea = unitRec.Saleable_Area__c;
            w.rentPerSqFt    = unitRec.Rent_per_uom_Price_per_uom__c;
            
            return w;
            
        } catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            throw new AuraHandledException('Feedback Form Error : ' + e.getMessage());
        }
    }
    // METHOD 1 — Save Signature to Field
    
    @AuraEnabled
    public static void saveSignature(Id siteVisitId, String signature) {
        
        System.debug('=== Save Signature Start ===');
        
        try {
            
            if(siteVisitId == null){
                throw new AuraHandledException('Site Visit Id is missing.');
            }
            
            if(String.isBlank(signature)){
                throw new AuraHandledException('Tenant signature is required.');
            }
            
            String richTextValue =
                '<img src="' + signature +
                '" alt="Tenant Signature" ' +
                'style="width:250px;height:100px;" />';
            
            Site_Visit__c sv = new Site_Visit__c(
                Id = siteVisitId,
                Tenant_Signature__c = richTextValue
            );
            update sv;
            
            System.debug('Signature saved successfully.');
            
        } catch(Exception e){
            System.debug('Save Signature Error : ' + e.getMessage());
            throw new AuraHandledException('Save Signature Failed : ' + e.getMessage());
        }
    }
    
    // METHOD 2 — Generate PDF (called from LWC after saveSignature)
    @AuraEnabled
    public static void generatePDF(Id siteVisitId, String size, Decimal chargeableArea, Decimal rentPerSqFt) {
        
        System.debug('=== Generate PDF Start ===');
        
        try {
            
            if(siteVisitId == null){
                throw new AuraHandledException('Site Visit Id is missing.');
            }
            
            // Call future method so signature is fully committed
            generatePDFFuture(siteVisitId, size, chargeableArea, rentPerSqFt);
            
            System.debug('Future PDF generation triggered.');
            
        } catch(Exception e){
            System.debug('Generate PDF Error : ' + e.getMessage());
            throw new AuraHandledException('Generate PDF Failed : ' + e.getMessage());
        }
    }
    
    // FUTURE METHOD — Runs after transaction commits
    // Queries fresh Tenant_Signature__c from DB
    @future(callout=true)
    public static void generatePDFFuture(Id siteVisitId, String size, Decimal chargeableArea, Decimal rentPerSqFt) {
        
        System.debug('=== Future PDF Generation Start ===');
        
        try {
            
            // Verify signature is saved
            Site_Visit__c sv = [SELECT Id, Tenant_Signature__c FROM Site_Visit__c WHERE Id = :siteVisitId LIMIT 1];
            System.debug('Signature in DB = ' + sv.Tenant_Signature__c);
            
            // Get unit details
            Wrapper details = getUnitDetails(siteVisitId);
            
            PageReference pdfPage = Page.FeedbackInspectionPDF;
            pdfPage.getParameters().put('siteVisitId',    String.valueOf(siteVisitId));
            pdfPage.getParameters().put('landlordName',   details.landlordName);
            pdfPage.getParameters().put('location',       details.location);
            pdfPage.getParameters().put('size',           size);
            pdfPage.getParameters().put('chargeableArea', String.valueOf(chargeableArea));
            pdfPage.getParameters().put('rentPerSqFt',    String.valueOf(rentPerSqFt));
            
            // Blob pdfBlob = pdfPage.getContentAsPDF();
            Blob pdfBlob;
            
            if(Test.isRunningTest()){
                pdfBlob = Blob.valueOf('Dummy PDF');
            }else{
                pdfBlob = pdfPage.getContentAsPDF();
            } 
            
            ContentVersion cv = new ContentVersion();
            cv.Title         = 'Feedback_Inspection_' + DateTime.now().format('yyyyMMddHHmmss');
            cv.PathOnClient  = 'FeedbackInspection.pdf';
            cv.VersionData   = pdfBlob;
            insert cv;
            
            ContentVersion insertedVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = insertedVersion.ContentDocumentId;
            cdl.LinkedEntityId    = siteVisitId;
            cdl.ShareType         = 'V';
            cdl.Visibility        = 'AllUsers';
            insert cdl;
            
            System.debug('PDF generated and linked successfully.');
            
        } catch(Exception e){
            System.debug('Future PDF Error : ' + e.getMessage());
        }
    }
}