/**
* @description This class is used to generate cost sheet document
*/
public without sharing class GenerateQuotePdf {
    
    /**
* @description This invocable method is used to generate cost sheet document
* @param requestLst
*/
    @InvocableMethod(label='Generate Quote Pdf' description='Generate Quote Pdf')
    public static  List<Response> execute(List<Request> requestLst){
        List<Response> responseList = new List<Response>();
        system.debug('requestLst--->'+ requestLst );
        List<Id> unitBundleIdSet = New List<Id>();
        for(Request req: requestLst){
            Type classType = Type.forName(null, 'DocumentGeneration');
            DocumentService service = (DocumentService)classType.newInstance();
            system.debug('req.OpportunityID'+req.OpportunityID);
            Response res=new Response();
            res.DocumentSize = service.GenerateQuotePdf(req.OpportunityID, req.Document);
            responseList.add(res);
        }
        return responseList;
    }
    
    /**
* @description This is request wrapper
*/
    public class Request{   
        
        @InvocableVariable(label = 'Opportunity Id' description = 'Id of Opportunity' required = true)
        public String OpportunityID;
        
        @InvocableVariable(label = 'Document Name' description = 'Document Name' required =false)
        public String Document;
        
    }
    public class Response{
        @InvocableVariable(label = 'Is Big Document?' description = 'Check the document size')
        public String DocumentSize;
    }
}