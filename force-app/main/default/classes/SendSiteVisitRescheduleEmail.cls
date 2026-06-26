public class SendSiteVisitRescheduleEmail {
	@InvocableMethod(label='Send Site Visit Reschedule Email')
    public static void sendEmail(List<EmailInput> inputList) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		OrgWideEmailAddress[] owaList = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'chennai@allwarehouses.in' LIMIT 1];
		Id owaId = (owaList.isEmpty()) ? null : owaList[0].Id;
        EmailTemplate template = [
            SELECT Id, DeveloperName, Body, HtmlValue, Subject 
            FROM EmailTemplate 
            WHERE DeveloperName = 'Site_Visit_Rescheduled'
            LIMIT 1
        ];
        for (EmailInput input : inputList) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            email.setToAddresses(new String[] { input.landlordEmail });
            if (input.ccEmails != null && !input.ccEmails.isEmpty()) {
                email.setCcAddresses(input.ccEmails);
            }
			email.setOrgWideEmailAddressId(owaId);
            String subject = template.Subject;
            subject = subject.replace('#PreviousDate', input.previousSiteVisitDate);
            subject = subject.replace('#RescheduledDate', input.rescheduleSiteVisitDate);
            
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('#Location', input.locationName);
            htmlBody = htmlBody.replace('#VisitDateTime', input.siteVisitdateTime);
            
            email.setSubject(subject);
            email.setHtmlBody(htmlBody);
            email.setPlainTextBody(htmlBody);
            emails.add(email);
        }

        Messaging.sendEmail(emails);
    }

    public class EmailInput {
        @InvocableVariable(label='Landlord Email' required=true)
        public String landlordEmail;

        @InvocableVariable(label='Location Name' required=true)
        public String locationName;

        @InvocableVariable(label='Site Visit Date & Time' required=true)
        public String siteVisitdateTime;

        @InvocableVariable(label='Previous Site Visit Date' required=true)
        public String previousSiteVisitDate;
        
        @InvocableVariable(label='Reschedule Site Visit Date' required=true)
        public String rescheduleSiteVisitDate;
        
        @InvocableVariable(label='CC Emails' required=false)
        public List<String> ccEmails;
    }
}