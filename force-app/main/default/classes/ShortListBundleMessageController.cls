public class ShortListBundleMessageController{
    private ApexPages.StandardController standardController;
    public Datetime siteVisitDate { get; set; }
    
    Public ShortListBundleMessageController(ApexPages.StandardController standardController) {
        string unitBundleId = ApexPages.currentPage().getParameters().get('Id');
    }
    
    public PageReference updateUnitBundleStatus()
    {
        string unitBundleId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('unitBundleId'+unitBundleId);
        if(unitBundleId != null && unitBundleId != ''){
            Unit_Bundle__c unitBundle =[SELECT Id,Opportunity__c,
                                        Opportunity__r.Account_Name__c,
                                        Opportunity__r.Enquiry__c,
                                        Opportunity__r.Enquiry__r.Name,
                                        Opportunity__r.Account_Name__r.PersonEmail
                                        FROM Unit_Bundle__c
                                        WHERE Id = : unitBundleId];
            if(siteVisitDate != null)
            {
                System.debug('siteVisitDate'+siteVisitDate);
                if(siteVisitDate < system.today())
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.Error_Message_For_Site_Visit_Past));
                    return null;
                }
                else
                {
                    Site_Visit__c siteVisit = New Site_Visit__c();
                    siteVisit.Unit_Bundle__c = unitBundleId;
                    siteVisit.Visit_Date_Time__c = siteVisitDate;
                    siteVisit.Name = unitBundle.Opportunity__r.Enquiry__r.Name+' '+ String.valueOf(siteVisitDate); 
                    siteVisit.Opportunity__c = unitBundle.Opportunity__c;
                    siteVisit.Enquiry__c = unitBundle.Opportunity__r.Enquiry__c;
                    siteVisit.Account__c = unitBundle.Opportunity__r.Account_Name__c ;
                    insert siteVisit;
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    List<EmailTemplate> emailTemp = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate 
                                                     where DeveloperName =: 'Template_for_Informing_about_Scheduling_Site_Visit_to_Tenant' limit 1];
                    OrgWideEmailAddress OWEA = [SELECT Id, Address From OrgWideEmailAddress
                                                WHERE Address =: System.label.Site_Mail ];

                    if(unitBundle.Opportunity__r.Account_Name__r.PersonEmail != null && unitBundle.Opportunity__r.Account_Name__r.PersonEmail != '')
                    {
                        system.debug('emailTemp'+emailTemp.size());
                        system.debug('email'+unitBundle.Opportunity__r.Account_Name__r.PersonEmail );
                        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemp[0].Id, null, siteVisit.Id);
                        mail.setToAddresses(new List<String>{unitBundle.Opportunity__r.Account_Name__r.PersonEmail });
                        mail.setSaveAsActivity(true);
                        mail.setOrgWideEmailAddressId(OWEA.id);
                        mails.add(mail);  
                      
                        if(!mails.isEmpty()){
                            system.debug('50');
                            try{
                               // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                                System.debug('Mail Sent:'+mail);
                            }
                            catch (Exception e) {
                                System.debug('Problem sending Email: '+ e.getMessage());
                            }
                        }
                    }
                    
                    unitBundle.Status__c = 'Shortlist by customer';
                    update unitBundle;
                    PageReference pr = new PageReference('/apex/ShortListBundleMessage');
                    pr.setRedirect(true);               
                    return pr;
                }
                
            }
            else
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }
    
}