/* 
     *@description       : Whenever the deal breaks in the path, we should know in which stage it was breaked test class
	  @author            : Ruban
	  @last modified on  : 29/04/2025
      
*/

@isTest
public class OpportunityHandlerTest {
   @isTest
    static void testOpportunityStageTracking() {
        
        Opportunity__c opp = new Opportunity__c(
            Name = 'Test Opportunity',
            Stage__c = 'Site Visit' 
        );
        
        Test.startTest();
        insert opp;
        
        opp.Stage__c = 'Qualified'; 
        update opp;
        Test.stopTest();

        Opportunity__c updatedOpp = [SELECT Id, Previous_Stage__c, Current_Stage__c FROM Opportunity__c WHERE Id = :opp.Id];

       
        System.assertEquals('Site Visit', updatedOpp.Previous_Stage__c, 'Previous Stage should be Site Visit');
        System.assertEquals('Qualified', updatedOpp.Current_Stage__c, 'Current Stage should be Qualified');
    }
}