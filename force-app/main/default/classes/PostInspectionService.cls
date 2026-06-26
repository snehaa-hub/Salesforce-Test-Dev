public class PostInspectionService {

    @InvocableMethod
    public static void sendReport(List<String> oppIds) {
        Id oppId = oppIds[0];
        Opportunity__c opp = [SELECT Enquiry__c FROM Opportunity__c WHERE Id = :oppId LIMIT 1];

        Enquiry__c enq = [SELECT Name, Email__c FROM Enquiry__c WHERE Id = :opp.Enquiry__c LIMIT 1];

        List<Site_Visit__c> visits = [SELECT Id, Visit_Date__c
                                              FROM Site_Visit__c
                                      WHERE Opportunity__c = :oppId AND Site_Visit_Status__c = 'Completed'AND Visit_Date__c = TODAY];

       /* if(visits.isEmpty()){
            return;
        }*/

        PageReference pdfPage = Page.SiteVisitPDF;
        pdfPage.getParameters().put('oppId', oppId);

        Blob pdfBlob;

        if(Test.isRunningTest()){
            pdfBlob = Blob.valueOf('Test PDF');
        } else {
            pdfBlob = pdfPage.getContent();
        }

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Post_Inspection_Report.pdf');
        attachment.setBody(pdfBlob);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new String[]{enq.Email__c});       
        mail.setSubject('Post Inspection Reports -- ' + enq.Name + ' | ' + String.valueOf(visits[0].Visit_Date__c));      

        mail.setPlainTextBody(
            'Dear ' + enq.Name + ',\n\n' +
            'Good day.\n\n' +
            'Please find attached the post-inspection reports dated ' + String.valueOf(visits[0].Visit_Date__c) + '.\n\n' +
            'Kindly review and share your feedback.\n\n' +
            'Regards,\nTeam'
        );

        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
}