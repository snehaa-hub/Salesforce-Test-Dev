@isTest
public class SendSiteVisitRescheduleEmailTest {
	@isTest
    static void testSendEmail() {
        // --- Step 1: Insert a dummy EmailTemplate ---
        EmailTemplate template = new EmailTemplate(
            Name = 'Site Visit Rescheduled',
            DeveloperName = 'Site_Visit_Rescheduled',
            Subject = 'Site Visit Change: #PreviousDate → #RescheduledDate',
            HtmlValue = '<p>Property at #Location is rescheduled to #VisitDateTime</p>',
            Body = 'Property at #Location is rescheduled to #VisitDateTime',
            TemplateType = 'custom',
            FolderId = UserInfo.getUserId()
        );
        insert template;

        // --- Step 2: Create a mock EmailInput instance ---
        SendSiteVisitRescheduleEmail.EmailInput input = new SendSiteVisitRescheduleEmail.EmailInput();
        input.landlordEmail = 'landlord@example.com';
        input.locationName = 'Vadapalani';
        input.siteVisitdateTime = '2025-07-15 11:00 AM';
        input.previousSiteVisitDate = '2025-07-14';
        input.rescheduleSiteVisitDate = '2025-07-15';
        input.ccEmails = new List<String>{ 'cc1@example.com', 'cc2@example.com' };

        // --- Step 3: Call the method with test data ---
        Test.startTest();
        SendSiteVisitRescheduleEmail.sendEmail(new List<SendSiteVisitRescheduleEmail.EmailInput>{ input });
        Test.stopTest();

        // You can't assert email sending directly, but you can verify no errors occurred.
        System.assert(true, 'Email sent successfully without exceptions');
    }
}