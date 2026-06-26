public class GenerateSiteVisitQuotePdf {
    @InvocableMethod(label='Generate Site Visit Quote Pdf')
    public static void execute(List<Request> requestLst){
        for(Request req: requestLst){
            Type classType = Type.forName(null, 'DocumentGeneration');
            DocumentService service = (DocumentService)classType.newInstance();
            service.GenerateSiteVisitQuotePdf(req.unitBundleId,req.OpportunityID,req.siteVisitId);
        }
    }
    public class Request{   
        @InvocableVariable(label = 'Unit Bundle Id' description = 'Id of Unit Bundle' required = true)
        public String unitBundleId;
        @InvocableVariable(label = 'Opportunity Id' description = 'Id of Opportunity' required = true)
        public String OpportunityID;
        @InvocableVariable(label = 'Site Visit Id' description = 'Id of Site Visit' required = true)
        public String siteVisitId;
    }
}