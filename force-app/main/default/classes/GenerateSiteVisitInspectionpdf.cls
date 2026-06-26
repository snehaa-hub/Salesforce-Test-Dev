public class GenerateSiteVisitInspectionpdf {
 @InvocableMethod(label='Generate Site Visit FeedBack Form Pdf')
        public static void execute(List<Request> requestLst){
        for(Request req: requestLst){
            Type classType = Type.forName(null, 'DocumentGeneration');
            DocumentService service = (DocumentService)classType.newInstance();
            service.GenerateSiteVisitInspectionPdf(req.OpportunityID, req.siteVisitId);
        }
    }
    public class Request{   
        @InvocableVariable(label = 'Opportunity Id' description = 'Id of Opportunity' required = true)
        public String OpportunityID;
        @InvocableVariable(label = 'Site Visit Id' description = 'Id of Site Visit' required = true)
        public String siteVisitId;
    }
}