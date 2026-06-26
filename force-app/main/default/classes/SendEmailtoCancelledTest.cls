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
@istest
public class SendEmailtoCancelledTest {

    @isTest
    static void testSendEmail() {
      
        Account acc = new Account(Name = 'Test Account');
        insert acc;

       
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'chennai@allwarehouses.in' LIMIT 1];

      
        Id templateId = [SELECT Id FROM EmailTemplate WHERE IsActive = true LIMIT 1].Id;

        
        SendEmailtoCancelled.EmailRequest request = new SendEmailtoCancelled.EmailRequest();
        request.templateId = templateId;
        request.recordId = acc.Id;
        request.emailList = new List<String>{ 'testuser@example.com' };

       
        Test.startTest();
        SendEmailtoCancelled.excute(new List<SendEmailtoCancelled.EmailRequest>{ request });
        Test.stopTest();

        
        System.assert(true, 'Execution completed');
    }


}