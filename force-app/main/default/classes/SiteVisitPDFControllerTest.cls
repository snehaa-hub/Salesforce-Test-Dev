@isTest
public class SiteVisitPDFControllerTest {

    @testSetup
    static void setupData() {

        //Record Type
        Id enqRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Enquiry__c'AND Name = 'Tenant' LIMIT 1].Id;

        //Enquiry
        Enquiry__c enq = new Enquiry__c(
            Name = 'K Gandhi',
            RecordTypeId = enqRT,
            Email__c = 'ram@gmail.com',
            Mobile__c = '919080715921',
            Status__c = 'New',
            Size_in_sqft__c = '10000 - 25000',
            Size_in_sqfts__c = 10050,
            Type_of_Unit__c = 'Land'
        );
        insert enq;

        //Required Child Record
        Interested_Locations__c loc = new Interested_Locations__c(Name = 'Test Location',Related_Enquiry__c = enq.Id,Interested_Location_Range__c = 5);
        insert loc;

        // Trigger Opportunity creation
        enq.Status__c = 'Closed';
        enq.Reason_for_Closed__c = 'Qualified';
        update enq;

        //Get or Create Opportunity
        List<Opportunity__c> oppList = [SELECT Id FROM Opportunity__c WHERE Enquiry__c = :enq.Id LIMIT 1];

        Opportunity__c opp;

        if(oppList.isEmpty()){
            opp = new Opportunity__c(Name = 'Test Opp',Enquiry__c = enq.Id);
            insert opp;
        } else {
            opp = oppList[0];
        }

        //Site Visit
        Site_Visit__c sv = new Site_Visit__c(
            Name = 'Visit 1',
            Opportunity__c = opp.Id,
            Status__c = 'Completed',
            Visit_Date_Time__c = System.now().addMinutes(10),
            Created_From__c = 'API',
            No_of_People_Planned__c = 2
        );
        insert sv;

        // Image 1
        ContentVersion cv1 = new ContentVersion(
            Title = 'Image 1',
            PathOnClient = 'img1.jpg',
            VersionData = Blob.valueOf('Data1'),
            IsMajorVersion = true
        );
        insert cv1;

        //Image 2 (IMPORTANT for img2 coverage)
        ContentVersion cv2 = new ContentVersion(
            Title = 'Image 2',
            PathOnClient = 'img2.jpg',
            VersionData = Blob.valueOf('Data2'),
            IsMajorVersion = true
        );
        insert cv2;

        // Fetch versions
        List<ContentVersion> cvs = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :new List<Id>{cv1.Id, cv2.Id}];

        // Link both images
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        for(ContentVersion cv : cvs){
            links.add(new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId,LinkedEntityId = sv.Id,ShareType = 'V'));
        }

        insert links;
    }

    //Main Test (Full Flow)
    @isTest
    static void testController() {

        Opportunity__c opp = [SELECT Id FROM Opportunity__c LIMIT 1];

        Test.setCurrentPage(Page.SiteVisitPDF);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);

        Test.startTest();
        SiteVisitPDFController ctrl = new SiteVisitPDFController();
        Test.stopTest();

        System.assert(ctrl.visits.size() > 0);
        System.assert(ctrl.pages.size() > 0);
        System.assertNotEquals(null, ctrl.visitImages);
    }

}