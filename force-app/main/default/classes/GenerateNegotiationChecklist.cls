/**
* @description This class is used to generate cost sheet document
*/
public without sharing class GenerateNegotiationChecklist {
    
    /**
* @description This invocable method is used to generate cost sheet document
* @param requestLst
*/
    @InvocableMethod(label='Generate Negotiatio Pdf' description='Generate Negotiatio Pdf')
    public static void execute(List<Request> requestLst){
        List<Id> unitBundleIdSet = New List<Id>();
        for(Request req: requestLst){
            Type classType = Type.forName(null, 'DocumentGeneration');
            DocumentService service = (DocumentService)classType.newInstance();
            service.GenerateNegotiationChecklistPdf(req.OpportunityID, req.unitBundleId, req.DocumentTittle);
        }
    }
    
    /**
* @description This is request wrapper
*/
    public class Request{   
       
        @InvocableVariable(label = 'Opportunity Id' description = 'Id of Opportunity' required = true)
        public String OpportunityID;
        
        @InvocableVariable(label = 'Unit Bundle Id' description = 'Id of Unit Bundle' required = true)
        public String unitBundleId;

        @InvocableVariable(label = 'Document Tittle' description = 'Tittle of Negotiation Checklist Document' required = true)
        public String DocumentTittle;
    }
}