public class SendHTMLEmailAction {
    
    @InvocableMethod(label='Send HTML Email' 
                     description='Sends HTML formatted email from Flow')
    public static void sendEmail(List<EmailRequest> requests) {
        
        List<Messaging.SingleEmailMessage> emails = 
            new List<Messaging.SingleEmailMessage>();
        
        for (EmailRequest req : requests) {
            Messaging.SingleEmailMessage email = 
                new Messaging.SingleEmailMessage();
            
            email.setToAddresses(new List<String>{ req.toAddress });
            email.setSubject(req.subject);
            email.setHtmlBody(req.htmlBody);
            email.setPlainTextBody('Please view this email in an HTML compatible client.');
            email.setSaveAsActivity(false);
            email.setUseSignature(false);
            emails.add(email);
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public class EmailRequest {
        
        @InvocableVariable(label='To Address' required=true)
        public String toAddress;
        
        @InvocableVariable(label='Subject' required=true)
        public String subject;
        
        @InvocableVariable(label='HTML Body' required=true)
        public String htmlBody;
    }
}