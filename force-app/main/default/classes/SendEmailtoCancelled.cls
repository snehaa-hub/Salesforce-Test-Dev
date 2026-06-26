/**
* @File Name : extractShortlistedUnitIdFromUnitOption.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 28, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 28, 2025 |   | Initial Version
**/


public class SendEmailtoCancelled {
    
    
    public class EmailRequest {
        @InvocableVariable(required=false)
        public Id templateId;
        
        @InvocableVariable(required=false)
        public Id recordId;
        
        @InvocableVariable(required=false)
        public List<String> emailList ;
        
    }
    
    
    
    @InvocableMethod(label='Send Email Using Template' description='Send an email using a template and custom addresses')
    public static void excute(List<EmailRequest> requests) {
        
         List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        List<String> emailList = new List<String>();
        List<String> ccList = new List<String>();
        ccList.add('pooja@allwarehouses.in');
        /* ccList.add('industrial@chattels.in');
   ccList.add('barathi@chattels.in'); */
        ccList.add('chennai@allwarehouses.in');
        System.debug('emailList'+ emailList);
         System.debug('ccList'+ ccList);
        
        
        OrgWideEmailAddress owea = [SELECT Id  FROM OrgWideEmailAddress WHERE Address = 'chennai@allwarehouses.in' LIMIT 1];
        
        for (EmailRequest req : requests) {
                  try {
                // Render the template
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(
                    req.templateId,
                    null, // whoId, optional – set if you want merge fields like Contact.FirstName
                    req.recordId // whatId – like Opportunity, Case, or a Custom Object
                );
                 System.debug('email'+ email);
                Messaging.SingleEmailMessage semail = new  Messaging.SingleEmailMessage();
                semail.setToAddresses(req.emailList);
                       System.debug('semail'+ req.emailList);
                semail.setCcAddresses(ccList);
                       System.debug('semail'+ ccList);
                semail.setSubject(email.getSubject());
                semail.setPlainTextBody(email.getPlainTextBody());
                semail.sethtmlBody(email.gethtmlBody());
                semail.setOrgWideEmailAddressId(owea.Id);
                sendEmailList.add(semail);
                       System.debug('semail'+ semail);
                    } 
            
            catch (Exception e) {
                        System.debug('Error sending email: ' + e.getMessage());
                    }
            
            
        }
        if(!sendEmailList.isEmpty()){
            try {
               
                Messaging.sendEmail(sendEmailList);
            }
            catch (Exception e) {
                System.debug('e'+e.getMessage());
                
            }
        }
        
        
    }
}