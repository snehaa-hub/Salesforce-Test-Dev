@IsTest
private class FeedbackInspectionPDFControllerTest {

    @IsTest
    static void testPDFController() {

        Site_Visit__c sv = new Site_Visit__c(
            Name = 'Test Visit',
            Tenant_Signature__c = 'Signature Data'
        );
        insert sv;

        Test.setCurrentPage(Page.FeedbackInspectionPDF);

        ApexPages.currentPage().getParameters().put(
            'siteVisitId',
            sv.Id
        );

        Test.startTest();
        FeedbackInspectionPDFController ctrl =
            new FeedbackInspectionPDFController();
        Test.stopTest();

        System.assertEquals(
            'Signature Data',
            ctrl.tenantSignature
        );
    }
/*
    @IsTest
    static void testControllerWithoutSiteVisitId() {

        Test.setCurrentPage(Page.FeedbackInspectionPDF);

        Test.startTest();
        FeedbackInspectionPDFController ctrl =
            new FeedbackInspectionPDFController();
        Test.stopTest();

        System.assertEquals(
            '',
            ctrl.tenantSignature
        );
    }*/
}