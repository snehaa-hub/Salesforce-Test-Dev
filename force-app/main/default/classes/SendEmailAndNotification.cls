/**
* @description This class is used to send email/notification to users with attachemnt from flow
*/
global without Sharing class SendEmailAndNotification {
    
    /**
    * @description This is invocable method used to send email/notification to users with attachemnt from flow
    * @param requestLst
    */
    @InvocableMethod(label='Send Email And Notification' description='Send Email And Notification')
    global static void execute(List<Request> requestLst){	
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        for(Request req : requestLst){ 
          // List<OrgWideEmailAddress> orgEmail = [select id, Address, DisplayName from OrgWideEmailAddress where Address = 'chennai@allwarehouses.in'];
		 List<OrgWideEmailAddress> orgEmail = [select id, Address, DisplayName from OrgWideEmailAddress where Address = 'risawh077@gmail.com'];// creates for the testing the email integration
			system.debug('orgemil'+ orgEmail);
            
            if(!requestLst.isEmpty()){
                Set<String> userIds = new Set<String>();
                Set<String> ContactIds = new Set<String>();
                List<String> emailList = new List<String>();
                List<String> ccList = new List<String>();
              //  ccList.add('pooja@allwarehouses.in');
                ccList.add('chennai@allwarehouses.in');

                //NEW — Add Account Email to CC for Non-Tenant Record Types
                if(req.accountEmail != null && req.accountEmail != ''){
                    ccList.add(req.accountEmail);
                }


                if(req.ContactList != null && !req.ContactList.isEmpty())
                {
                    for(Contact contact: req.ContactList){
                        if(contact.Email != null)
                        {
                            emailList.add(contact.Email);
                        }
                        
                        ContactIds.add(contact.Id);
                    }
                }

                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                if(req.contentVersionList != null && !(req.contentVersionList).isEmpty()){
                    for(ContentVersion cv : req.contentVersionList){
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(cv.Title); 
                        efa.setBody(cv.VersionData);
                        attachments.add(efa);
                    }
                }

                // Opportunity__c opp = [SELECT Id, 
                //                             Enquiry__r.Id, Enquiry__r.Name,Enquiry__r.Size_in_sqfts__c
                //                              FROM Opportunity__c where Id =: req.recordId];

                System.debug('req.sendEmail '+req.sendEmail );
                System.debug('req.emailTemplateId '+req.emailTemplateId );
                System.debug('req.landemailTemplateId '+req.landemailTemplateId );

                /*
                =====================================================================
                MAIN TEMPLATE EMAIL FOR CLIENT (ONLY THIS ONE GETS SUBJECT = FILE NAME)
                =====================================================================
                */

                // NEW — Non-Tenant Path (Enquiry Email in TO, Account Email in CC)
                if(req.enquiryEmail != null && req.enquiryEmail != ''){
                    System.debug('Non-Tenant path - sending to Enquiry email');
                    Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(req.emailTemplateId, null, req.recordId);
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    semail.setToAddresses(new List<String>{req.enquiryEmail});
                    semail.setCcAddresses(ccList);
                    String subject = message.getSubject();
                    if (!attachments.isEmpty()) {
                        subject = attachments[0].getFileName();
                    }
                    semail.setSubject(subject);
                    semail.setPlainTextBody(message.getPlainTextBody());
                    semail.sethtmlBody(message.gethtmlBody());
                    if(!orgEmail.isEmpty()) {
                        semail.setOrgWideEmailAddressId(orgEmail[0].id);
                    }
                    
                    if(!attachments.isEmpty()){
                        semail.setFileAttachments(attachments);
                    }
                    sendEmailList.add(semail);
                }

                else if(req.sendEmail == true && !String.isBlank(req.emailTemplateId) && (!ContactIds.isEmpty() && ContactIds != null)){
                    
                    if(!ContactIds.isEmpty() && ContactIds != null){

                        for(String contactId: ContactIds){
                            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(req.emailTemplateId,contactId , req.recordId);
                            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                            semail.setToAddresses(req.emailList);
                            semail.setCcAddresses(ccList);

                            String subject = message.getSubject();
                            // String squarefeet;
                            // if (opp.Enquiry__r.Size_in_sqfts__c == null) {
                            //     squarefeet = ''; 
                            // } else {
                            //     squarefeet = String.valueOf(opp.Enquiry__r.Size_in_sqfts__c)+'sqft';
                            // }
                            // subject = subject.replace('#Name', opp.Enquiry__r.Name);
                            // subject = subject.replace('#Squarefeet',squarefeet);

                            // ----------------------------------------------------------
                            // SUBJECT OVERRIDE: Always set subject as file name for proposal email
                            // (NO CHECK FOR 'proposal', ALWAYS OVERRIDE)
                            // ----------------------------------------------------------
                            if (!attachments.isEmpty()) {
                                subject = attachments[0].getFileName();
                            }
                            // ----------------------------------------------------------

                            semail.setSubject(subject);
                            semail.setPlainTextBody(message.getPlainTextBody());
                            
                            if(!orgEmail.isEmpty()) {
                                semail.setOrgWideEmailAddressId(orgEmail[0].id);
                            }
                            semail.sethtmlBody(message.gethtmlBody());
                            if(!attachments.isEmpty()){
                                semail.setFileAttachments(attachments);
                            }
                            sendEmailList.add(semail);
                        }
                    }

                } 
                
                else if(ContactIds.isEmpty()) {

                    // CLIENT EMAIL WITHOUT CONTACTS (NO OVERRIDE)
                    if(req.emailTemplateId !=''){
                        System.debug('email for tenant');
                        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(req.emailTemplateId,null , req.recordId);
                        System.debug('message----------->'+message);
                        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                        semail.setToAddresses(req.emailList);
                        semail.setSubject(message.getSubject());
                        semail.setPlainTextBody(message.getPlainTextBody());
                        semail.sethtmlBody(message.gethtmlBody());
                        semail.setCcAddresses(ccList);
                        System.debug('semail----------->'+semail);
                        if(!orgEmail.isEmpty()) {
                            semail.setOrgWideEmailAddressId(orgEmail[0].id);
                        }
                        if(!attachments.isEmpty()){
                            semail.setFileAttachments(attachments);
                        }
                        sendEmailList.add(semail);
                    }
                   
                    // LANDLORD EMAIL (NO OVERRIDE)
                    if(req.landemailTemplateId !='' && req.landemailTemplateId != null){
                        System.debug('email for landlord');
                        Messaging.SingleEmailMessage message2 = Messaging.renderStoredEmailTemplate(req.landemailTemplateId, null, req.recordId);
                        System.debug('message2----------->'+message2);
                        Messaging.SingleEmailMessage semail2 = new Messaging.SingleEmailMessage();
                        semail2.setToAddresses(req.emailLandList);
                        semail2.setSubject(message2.getSubject());
                        semail2.setPlainTextBody(message2.getPlainTextBody());
                        semail2.setHtmlBody(message2.getHtmlBody());
                        semail2.setCcAddresses(ccList);
                        System.debug('semail2----------->'+semail2);
                        if(!orgEmail.isEmpty()) {
                            semail2.setOrgWideEmailAddressId(orgEmail[0].Id);
                        }
                        if(!attachments.isEmpty()) {
                            semail2.setFileAttachments(attachments);
                        }
                        sendEmailList.add(semail2); 
                    }
                            
                } 
                
                // PLAIN EMAIL (NO OVERRIDE)
                else if(req.sendEmail == true && !String.isBlank(req.title) && !String.isBlank(req.body)) {
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    semail.setToAddresses(emailList);
                    semail.setSubject(req.title);
                    semail.setPlainTextBody(req.body);
                    semail.sethtmlBody(req.body);
                    semail.setCcAddresses(ccList);

                    if(!orgEmail.isEmpty()) {
                        semail.setOrgWideEmailAddressId(orgEmail[0].id);
                    }
                    if(!attachments.isEmpty()){
                        semail.setFileAttachments(attachments);
                    }
                    sendEmailList.add(semail);
                }
                
                if(req.sendNotification == true && !String.isBlank(req.title) && !String.isBlank(req.body) && !String.isBlank(req.notificationTypeId)){
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle(req.title);
                    notification.setBody(req.body);
                    notification.setNotificationTypeId(req.notificationTypeId);
                    notification.setTargetId(req.recordId);

                    try {
                        notification.send(userIds);
                    }
                    catch (Exception e) {
                        throw e;
                    }
                }
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
    
    /**
    * @description Request wrapper that input values required to send email/notification
    */
    global class Request{
        @InvocableVariable(label = 'Record Id' description = 'Record Id' required = true)
        global String recordId;
        
        @InvocableVariable(label = 'Email Template Id' description = 'Email Template Id' required = false)
        global String emailTemplateId;

        @InvocableVariable(label = 'Land Email Template Id' description = 'Email Template Id' required = false)
        global String landemailTemplateId;
        
        @InvocableVariable(label = 'Send Email' description = 'Send Email' required = false)
        global Boolean sendEmail;
        
        @InvocableVariable(label = 'Send Notification' description = 'Send Notification' required = false)
        global Boolean sendNotification;
        
        @InvocableVariable(label = 'Notification Type Id' description = 'Notification Type Id' required = false)
        global String notificationTypeId;
        
        @InvocableVariable(label = 'Title' description = 'Title/Subject' required = false)
        global String title;
        
        @InvocableVariable(label = 'Body' description = 'Body' required = false)
        global String body;
        
        @InvocableVariable(label = 'Users' description = 'List of Users' required = false)
        global List<User> userList;
        
        @InvocableVariable(label = 'Contacts' description = 'List of Contact' required = false)
        global List<Contact> ContactList;
        
        @InvocableVariable(label = 'Emails' description = 'List of Email' required = false)
        global List<String> emailList;
        
        @InvocableVariable(label = 'Emails For Landlord' description = 'List of Email' required = false)
        global List<String> emailLandList;

        @InvocableVariable(label = 'CC Emails' description = 'List of CC Emails' required = false)
        global List<String> ccEmailList;  //Added By Arun - to populate the Enquiry email in the CC field for sending the proposal (17-03-26)

        @InvocableVariable(label = 'Content Versions' description = 'If attachment needs to be send pass List of content version' required = false)
        global List<ContentVersion> contentVersionList;


        //NEW — Enquiry Email for TO (Non-Tenant Record Types)
        @InvocableVariable(label = 'Enquiry Email' description = 'Enquiry Email for TO' required = false)
        global String enquiryEmail;

        //NEW — Account Email for CC (Non-Tenant Record Types)
        @InvocableVariable(label = 'Account Email' description = 'Account Email for CC' required = false)
        global String accountEmail;
    }
}