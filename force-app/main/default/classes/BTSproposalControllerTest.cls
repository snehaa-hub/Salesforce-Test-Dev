/**
* @File Name : GpsCameraImageController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 22, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 21, 2025 |   | Initial Version
**/
@isTest
public class BTSproposalControllerTest {
    
    @isTest
    static void testBTSProposalController() {
        // Step 1: Create a test Opportunity__c with JSON in Proposal_Json__c
        Opportunity__c opp = new Opportunity__c(
            Name = 'Test Opportunity',
            Proposal_Json__c = '[{"Id":"001","Name":"Test Bundle","UnitData":[{"Data":{"Name":"Unit1"},"selectedContentVersionID":["12345"]}]}]',
            Share_Location__c = true,
            Landlord_Name__c = true,
            Landlord_Mobile__c = true
        );
        insert opp;


        // Step 3: Set parameters for the controller
        Test.setCurrentPage(Page.BTSProposal); // Replace with actual VF page name
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        ApexPages.currentPage().getParameters().put('selectedFields', 'Landlord_Name__c,Landlord_Mobile__c');

        // Step 4: Instantiate controller
        Test.startTest();
        BTSProposalController controller = new BTSProposalController();
        Test.stopTest();

        
        
        // Step 5: Assertions
        System.assertNotEquals(null, controller.unitBundles, 'UnitBundles should not be null');
        System.assert(controller.googleMapLinkShare, 'Google Map link share should be true');
        System.assert(controller.landlordName, 'Landlord name should be true');
        System.assert(controller.landlordMobile, 'Landlord mobile should be true');
        System.assert(controller.showField('Landlord_Name__c'), 'Field should be shown');
        System.assert(!controller.showField('NonExistentField'), 'Field should not be shown');
        
        for (BTSProposalController.UnitBundle bundle : controller.unitBundles) {
            String testUrl = bundle.Url;
            System.debug('Generated URL: ' + testUrl);
            System.assert(testUrl.contains('?id='), 'URL should include ID query param');
        }
    }
}