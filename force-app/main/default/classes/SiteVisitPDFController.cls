public class SiteVisitPDFController{
    
    public List<Site_Visit__c> visits {get;set;}
    public Map<Id, List<ContentVersion>> visitImages {get;set;}
    public List<PageWrapper> pages {get;set;}
    
    public class PageWrapper { 
        public Site_Visit__c visit {get;set;}
        public ContentVersion img1 {get;set;}
        public ContentVersion img2 {get;set;}
        public Integer pageNumber {get;set;}
        public Boolean isLastPage {get;set;}
    }
    
    public SiteVisitPDFController(){
        
        Id oppId = ApexPages.currentPage().getParameters().get('oppId');
        if(oppId == null) return;
        
        visits = [SELECT Id, Name, Unit_Bundle__r.Name,Enquiry__r.Name, Opportunity__r.Name,Visit_Date_Time__c, Site_Visit_Status__c, No_of_People_Planned__c
                  FROM Site_Visit__c
                  WHERE Opportunity__c = :oppId AND Site_Visit_Status__c = 'Completed'AND Visit_Date__c = TODAY  ORDER BY CreatedDate ASC];
        
        if(visits.isEmpty()) return;
        
        Set<Id> visitIds = new Set<Id>();
        for(Site_Visit__c v : visits){
            visitIds.add(v.Id);
        }
        
        List<ContentDocumentLink> links = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :visitIds];
        
        Set<Id> docIds = new Set<Id>();
        for(ContentDocumentLink l : links){
            docIds.add(l.ContentDocumentId);
        }
        
        List<ContentVersion> versions = [SELECT Id, ContentDocumentId, CreatedDate FROM ContentVersion WHERE ContentDocumentId IN :docIds ];
        
        Map<Id, List<ContentVersion>> docMap = new Map<Id, List<ContentVersion>>();
        
        for(ContentVersion v : versions){
            if(!docMap.containsKey(v.ContentDocumentId)){
                docMap.put(v.ContentDocumentId, new List<ContentVersion>());
            }
            docMap.get(v.ContentDocumentId).add(v);
        }
        
        visitImages = new Map<Id, List<ContentVersion>>();
        
        for(ContentDocumentLink l : links){
            if(!visitImages.containsKey(l.LinkedEntityId)){
                visitImages.put(l.LinkedEntityId, new List<ContentVersion>());
            }
            if(docMap.containsKey(l.ContentDocumentId)){
                visitImages.get(l.LinkedEntityId).addAll(docMap.get(l.ContentDocumentId));
            }
        }
        
        pages = new List<PageWrapper>();
        Integer pg = 1;
        
        for(Site_Visit__c v : visits){
            
            List<ContentVersion> imgs = visitImages.get(v.Id);
            
            PageWrapper p = new PageWrapper();
            p.visit = v;
            
            if(imgs != null && !imgs.isEmpty()){
                p.img1 = imgs[0];
                if(imgs.size() > 1){
                    p.img2 = imgs[1];
                }
            }
            p.pageNumber = pg;
            pg++;
            pages.add(p);
        }
        if(!pages.isEmpty()){
            pages[pages.size()-1].isLastPage = true;
        }
    }
}