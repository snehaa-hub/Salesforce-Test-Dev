/**
 * @description This is interface class that is used in generating documents.
 */
global interface DocumentService {
    /**
     * @description This methos is used to generate cost sheet document.
     * @param unitBundleId
     */
    String GenerateQuotePdf(String OpportunityID,String Document);
    void GenerateNegotiationChecklistPdf(String OpportunityID, String unitBundleId, String DocumentTittle);
    void GenerateSiteVisitQuotePdf(String unitBundleId, String OpportunityID, String siteVisitId);
   // void SiteVisitInspectionChecklistPdf(String OpportunityID, String siteVisitId);
   void GenerateSiteVisitInspectionpdf(String OpportunityID, String siteVisitId);
	//Void GenerateProposalForSiteOwner(String unitBundleId, String OpportunityID);
}