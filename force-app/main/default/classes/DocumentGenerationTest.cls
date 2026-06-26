/**
* @File Name : DocumentGenerationTest.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 16, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 16, 2025 |   | Initial Version
**/
@isTest
public class DocumentGenerationTest {
	
    // Create common test data
    static testMethod void testGenerateQuotePdf() {
		 // Create Account
		 RecordType rc = [SELECT Id, Name, DeveloperName, SObjectType 
FROM RecordType 
WHERE SObjectType = 'Account' 
AND DeveloperName = 'PersonAccount'];
		 Account acc = new Account(LastName='Test Name',RecordTypeId = rc.Id);
        insert acc;
	Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Enquiry__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }
    // Create Enquiry__c with the RecordType
    Enquiry__c enquiry = new Enquiry__c(
        Name = 'Test Enquiry',
        RecordTypeId = rtMap.get('Landlord'),
        Status__c = 'New', 
    	Email__c = 'test@example.com',
        Contact_Person__c = acc.Id,
        Mobile__c='1234567890'
    );
    insert enquiry;

    // Create Opportunity__c
    Opportunity__c opp = new Opportunity__c(
        Name = 'Test Opportunity',
        Property_Type__c = 'Leasing',
        Account_Name__c = acc.Id,
        Enquiry__c = enquiry.Id,
        Share_Location__c = true,
        Landlord_Name__c = true,
        Landlord_Mobile__c = true
    );
    insert opp;
        Unit__c unit = new Unit__c(
            Name = 'Test BTS Unit',
            Type_of_Unit__c = 'BTS',
            Size_Range__c = 'below 10000'
        );
        insert unit;
	String Name = 'Test Negotiation_Checklist__c';
            String Value = 'qwerty';
            Integer SequenceNo = 2;
            String DefaultValue = 'abcd';
    String checklistJSON = JSON.serialize(new List<Object>{
    new Map<String, Object>{
        'Name' => Name,
        'Value' => Value,
        'SequenceNo' => SequenceNo,
        'DefaultValue' => DefaultValue,
        'AdditionalValue' => 'Test',
        'IsMainHeading' => 'true',
        'IsHeading' => 'true',
        'IsSubLabel' => 'true',
        'colSpan' => 2,
        'colSpan2' => 3,
        'sequenceVisible' => 'true',
        'AdditionalVisible' => 'true',
        'Disclaimer' => 'false'
    },
    new Map<String, Object>{
        'Name' => 'Checklist 2',
        'Value' => 'val2',
        'SequenceNo' => 3,
        'DefaultValue' => 'def2',
        'AdditionalValue' => 'Extra',
        'IsMainHeading' => 'false',
        'IsHeading' => 'false',
        'IsSubLabel' => 'true',
        'colSpan' => 1,
        'colSpan2' => 1,
        'sequenceVisible' => 'false',
        'AdditionalVisible' => 'false',
        'Disclaimer' => 'true'
    }
});

    // Create Unit_Bundle__c
    Unit_Bundle__c bundle = new Unit_Bundle__c(
        Name = 'Test Bundle',
        Opportunity__c = opp.Id,
        Negotiation_Checklist__c = checklistJson
       
    );
    insert bundle;
        // Create Shortlisted_Unit__c
        Shortlisted_Unit__c  shortunit = new Shortlisted_Unit__c(

            Opportunity__c = opp.Id,
            Unit_Bundle__c = bundle.Id,
            Unit__c = unit.Id
        );
        insert shortunit;

        Test.startTest();
        Test.setCurrentPage(Page.QuotePdf); // For BTS
        DocumentGeneration gen = new DocumentGeneration();
        gen.GenerateQuotePdf(opp.Id,'LeasingProposal.Pdf');
        Test.stopTest();

       List<ContentVersion> cvs = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE '%Leasing%'];
        System.assert(!cvs.isEmpty(), 'ContentVersion for Land should be inserted');
    }
     @isTest
    static void testGenerateQuotePdf_Land() {
        Opportunity__c opp = new Opportunity__c(
            Name = 'Test Opp Land',
            Property_Type__c = 'Land',
            Share_Location__c = false,
            Landlord_Name__c = false,
            Landlord_Mobile__c = false
        );
        insert opp;

        Unit__c unit = new Unit__c(
            Name = 'Test Unit',
            Type_of_Unit__c = 'BTS',
            Size_Range__c = 'below 10000'
            
        );
        insert unit;

        Shortlisted_Unit__c shortlist = new Shortlisted_Unit__c(
            Opportunity__c = opp.Id,
            Unit__c = unit.Id
        );
        insert shortlist;

        Test.startTest();
        Test.setCurrentPage(Page.LandProposal); // For Land
        new DocumentGeneration().GenerateQuotePdf(opp.Id,'LandProposal.Pdf'); 
        Test.stopTest();

        List<ContentVersion> cvs = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE '%Land%'];
        System.assert(!cvs.isEmpty(), 'ContentVersion for Land should be inserted');
    }
	 @isTest
    static void testGenerateQuotePdf_BTS() {
        Opportunity__c opp = new Opportunity__c(
            Name = 'Test Opp BTS',
            Property_Type__c = 'BTS',
            Share_Location__c = true,
            Landlord_Name__c = true,
            Landlord_Mobile__c = false
        );
        insert opp;

        Unit__c unit = new Unit__c(
            Name = 'Test BTS Unit',
            Type_of_Unit__c = 'BTS',
            Size_Range__c = 'below 10000'
        );
        insert unit;

        Shortlisted_Unit__c shortlist = new Shortlisted_Unit__c(
            Opportunity__c = opp.Id,
            Unit__c = unit.Id
        );
        insert shortlist;

        Test.startTest();
        Test.setCurrentPage(Page.BTSProposal); // For BTS
        new DocumentGeneration().GenerateQuotePdf(opp.Id,'BTSProposal.Pdf'); 
        Test.stopTest();

        List<ContentVersion> cvs = [SELECT Id, Title FROM ContentVersion WHERE Title LIKE '%BTS%'];
        System.assert(!cvs.isEmpty(), 'ContentVersion for BTS should be inserted');
    }
    
    static testMethod void testGenerateNegotiationChecklistPdf() {
        // Create Account
		RecordType rc = [SELECT Id, Name, DeveloperName, SObjectType 
FROM RecordType 
WHERE SObjectType = 'Account' 
AND DeveloperName = 'PersonAccount'];
		 Account acc = new Account(LastName='Test Name',RecordTypeId = rc.Id);
        insert acc;
	Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Enquiry__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }
    // Create Enquiry__c with the RecordType
    Enquiry__c enquiry = new Enquiry__c(
        Name = 'Test Enquiry',
        RecordTypeId = rtMap.get('Landlord'),
        Status__c = 'New', 
    	Email__c = 'test@example.com',
        Contact_Person__c = acc.Id,
        Mobile__c='1234567890'
    );
    insert enquiry;

    // Create Opportunity__c
    Opportunity__c opp = new Opportunity__c(
        Name = 'Test Opportunity',
        Account_Name__c = acc.Id,
        Enquiry__c = enquiry.Id
    );
    insert opp;
        
	String Name = 'Test Negotiation_Checklist__c';
            String Value = 'qwerty';
            Integer SequenceNo = 2;
            String DefaultValue = 'abcd';
    String checklistJSON = JSON.serialize(new List<Object>{
    new Map<String, Object>{
        'Name' => Name,
        'Value' => Value,
        'SequenceNo' => SequenceNo,
        'DefaultValue' => DefaultValue,
        'AdditionalValue' => 'Test',
        'IsMainHeading' => 'true',
        'IsHeading' => 'true',
        'IsSubLabel' => 'true',
        'colSpan' => 2,
        'colSpan2' => 3,
        'sequenceVisible' => 'true',
        'AdditionalVisible' => 'true',
        'Disclaimer' => 'false'
    },
    new Map<String, Object>{
        'Name' => 'Checklist 2',
        'Value' => 'val2',
        'SequenceNo' => 3,
        'DefaultValue' => 'def2',
        'AdditionalValue' => 'Extra',
        'IsMainHeading' => 'false',
        'IsHeading' => 'false',
        'IsSubLabel' => 'true',
        'colSpan' => 1,
        'colSpan2' => 1,
        'sequenceVisible' => 'false',
        'AdditionalVisible' => 'false',
        'Disclaimer' => 'true'
    }
});

    // Create Unit_Bundle__c
    Unit_Bundle__c bundle = new Unit_Bundle__c(
        Name = 'Test Bundle',
        Opportunity__c = opp.Id,
        Negotiation_Checklist__c = checklistJson
       
    );
    insert bundle;


        Test.startTest();
        DocumentGeneration gen = new DocumentGeneration();
        gen.GenerateNegotiationChecklistPdf(opp.Id, bundle.Id, 'Test');
        Test.stopTest();

        List<ContentVersion> conList = [SELECT Id FROM ContentVersion WHERE Document_Type__c = 'Negotiation Checklist'];
        System.assertEquals(1, conList.size(), 'Negotiation Checklist PDF should be inserted');
    }

    static testMethod void testGenerateSiteVisitQuotePdf() {
         // Create Account
		 RecordType rc = [SELECT Id, Name, DeveloperName, SObjectType 
FROM RecordType 
WHERE SObjectType = 'Account' 
AND DeveloperName = 'PersonAccount'];
		 Account acc = new Account(LastName='Test Name',RecordTypeId = rc.Id);
        insert acc;
	Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Enquiry__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }
    // Create Enquiry__c with the RecordType
    Enquiry__c enquiry = new Enquiry__c(
        Name = 'Test Enquiry',
        RecordTypeId = rtMap.get('Landlord'),
        Status__c = 'New', 
    	Email__c = 'test@example.com',
        Contact_Person__c = acc.Id,
        Mobile__c='1234567890'
    );
    insert enquiry;

    // Create Opportunity__c
    Opportunity__c opp = new Opportunity__c(
        Name = 'Test Opportunity',
        Account_Name__c = acc.Id,
        Enquiry__c = enquiry.Id
    );
    insert opp;
        
	String Name = 'Test Negotiation_Checklist__c';
            String Value = 'qwerty';
            Integer SequenceNo = 2;
            String DefaultValue = 'abcd';
    String checklistJSON = JSON.serialize(new List<Object>{
    new Map<String, Object>{
        'Name' => Name,
        'Value' => Value,
        'SequenceNo' => SequenceNo,
        'DefaultValue' => DefaultValue,
        'AdditionalValue' => 'Test',
        'IsMainHeading' => 'true',
        'IsHeading' => 'true',
        'IsSubLabel' => 'true',
        'colSpan' => 2,
        'colSpan2' => 3,
        'sequenceVisible' => 'true',
        'AdditionalVisible' => 'true',
        'Disclaimer' => 'false'
    },
    new Map<String, Object>{
        'Name' => 'Checklist 2',
        'Value' => 'val2',
        'SequenceNo' => 3,
        'DefaultValue' => 'def2',
        'AdditionalValue' => 'Extra',
        'IsMainHeading' => 'false',
        'IsHeading' => 'false',
        'IsSubLabel' => 'true',
        'colSpan' => 1,
        'colSpan2' => 1,
        'sequenceVisible' => 'false',
        'AdditionalVisible' => 'false',
        'Disclaimer' => 'true'
    }
});

    // Create Unit_Bundle__c
    Unit_Bundle__c bundle = new Unit_Bundle__c(
        Name = 'Test Bundle',
        Opportunity__c = opp.Id,
        Negotiation_Checklist__c = checklistJson
       
    );
    insert bundle;


        // Create Site_Visit__c
        Site_Visit__c sv = new Site_Visit__c(Name='Visit 1', Opportunity__c = opp.Id, Unit_Bundle__c = bundle.Id);
        insert sv;
        PageReference ref = Page.SiteVisitQuotePdf;
		ref.getParameters().put('id',bundle.Id);
        Test.startTest();
        DocumentGeneration gen = new DocumentGeneration();
        gen.GenerateSiteVisitQuotePdf(bundle.Id, opp.Id, sv.Id);
        Test.stopTest();

        List<ContentVersion> conList = [SELECT Id FROM ContentVersion WHERE Title = 'Site Visit Proposal.pdf'];
       // System.assertEquals(1, conList.size(), 'Site Visit Proposal PDF should be inserted');
    }

    static testMethod void testGenerateSiteVisitInspectionpdf() {
           RecordType rc = [SELECT Id, Name, DeveloperName, SObjectType 
FROM RecordType 
WHERE SObjectType = 'Account' 
AND DeveloperName = 'PersonAccount'];
		 Account acc = new Account(LastName='Test Name',RecordTypeId = rc.Id);
        insert acc;
	Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Enquiry__c']) {
            rtMap.put(rt.DeveloperName, rt.Id);
        }
    // Create Enquiry__c with the RecordType
    Enquiry__c enquiry = new Enquiry__c(
        Name = 'Test Enquiry',
        RecordTypeId = rtMap.get('Landlord'),
        Status__c = 'New', 
    	Email__c = 'test@example.com',
        Contact_Person__c = acc.Id,
        Mobile__c='1234567890'
    );
    insert enquiry;

    // Create Opportunity__c
    Opportunity__c opp = new Opportunity__c(
        Name = 'Test Opportunity',
        Account_Name__c = acc.Id,
        Enquiry__c = enquiry.Id
    );
    insert opp;
        
	String Name = 'Test Negotiation_Checklist__c';
            String Value = 'qwerty';
            Integer SequenceNo = 2;
            String DefaultValue = 'abcd';
    String checklistJSON = JSON.serialize(new List<Object>{
    new Map<String, Object>{
        'Name' => Name,
        'Value' => Value,
        'SequenceNo' => SequenceNo,
        'DefaultValue' => DefaultValue,
        'AdditionalValue' => 'Test',
        'IsMainHeading' => 'true',
        'IsHeading' => 'true',
        'IsSubLabel' => 'true',
        'colSpan' => 2,
        'colSpan2' => 3,
        'sequenceVisible' => 'true',
        'AdditionalVisible' => 'true',
        'Disclaimer' => 'false'
    },
    new Map<String, Object>{
        'Name' => 'Checklist 2',
        'Value' => 'val2',
        'SequenceNo' => 3,
        'DefaultValue' => 'def2',
        'AdditionalValue' => 'Extra',
        'IsMainHeading' => 'false',
        'IsHeading' => 'false',
        'IsSubLabel' => 'true',
        'colSpan' => 1,
        'colSpan2' => 1,
        'sequenceVisible' => 'false',
        'AdditionalVisible' => 'false',
        'Disclaimer' => 'true'
    }
});

    // Create Unit_Bundle__c
    Unit_Bundle__c bundle = new Unit_Bundle__c(
        Name = 'Test Bundle',
        Opportunity__c = opp.Id,
        Negotiation_Checklist__c = checklistJson
       
    );
    insert bundle;

        // Create Site_Visit__c
        Site_Visit__c sv = new Site_Visit__c(Name='Visit 1', Opportunity__c = opp.Id, Unit_Bundle__c = bundle.Id);
        insert sv;


        Test.startTest();
        DocumentGeneration gen = new DocumentGeneration();
        gen.GenerateSiteVisitInspectionpdf(opp.Id, sv.Id);
        Test.stopTest();

        //List<ContentVersion> conList = [SELECT Id FROM ContentVersion WHERE Title = 'FeedBack Form.pdf'];
        //System.assertEquals(1, conList.size(), 'Feedback Form PDF should be inserted');
    }
}