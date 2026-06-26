public class SiteVisitInspectionFormController {
 public List<Wrapper> wrapList {get;set;}
    public SiteVisitInspectionFormController(){
        string siteVisitId;
        List<Wrapper> checklistList = New List<Wrapper>();
        siteVisitId = ApexPages.CurrentPage().getparameters().get('Id');
        String currentUserId = UserInfo.getUserId();
        if(siteVisitId!= null){
    	Site_Visit__c siteVisit = [ SELECT Id,
                               		Name, 
                               		Site_Visit_Inspection_Checklist__c 
                                	FROM Site_Visit__c
                                	WHERE Id = :siteVisitId
                                	LIMIT 1
        						];
            if(siteVisit != null){
                System.debug('siteVisit.Site_Visit_Inspection_Checklist__c' +siteVisit.Site_Visit_Inspection_Checklist__c);
                if(siteVisit.Site_Visit_Inspection_Checklist__c != null && siteVisit.Site_Visit_Inspection_Checklist__c != '')
                {
                 System.debug('siteVisit.Site_Visit_Inspection_Checklist__c' +siteVisit.Site_Visit_Inspection_Checklist__c); 
				  wrapList = (List<Wrapper>) JSON.deserialize(siteVisit.Site_Visit_Inspection_Checklist__c, List<Wrapper>.class);
                  System.debug('wrapList26:' + wrapList);
                }
           }
        }
        
    }
    Public Class Wrapper{
        Public String Name{get;set;}
        Public String Value{get;set;}
        Public String SequenceNo{get;set;}
        Public String Datatype{get;set;}
        
    }
   
}