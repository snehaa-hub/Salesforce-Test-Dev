public without sharing class FeedbackInspectionPDFController {
    
    public String tenantSignature { get; set; }
    
    public FeedbackInspectionPDFController() {
        String siteVisitId = ApexPages.currentPage().getParameters().get('siteVisitId');
        
        System.debug('=== PDF Controller Start ===');
        System.debug('siteVisitId = ' + siteVisitId);
        
        if(String.isNotBlank(siteVisitId)) {
            List<Site_Visit__c> svList = [
                SELECT Id, Tenant_Signature__c
                FROM Site_Visit__c
                WHERE Id = :siteVisitId
                LIMIT 1
            ];
            
            if(!svList.isEmpty()) {
                tenantSignature = svList[0].Tenant_Signature__c;
                System.debug('Tenant Signature = ' + tenantSignature);
            }
        }
        
        if(String.isBlank(tenantSignature)) {
            tenantSignature = '';
        }
    }
}