@isTest
public class CheckAndLinkUnit_Test {
    @isTest
    static void testExecute_NewUnitBundle() {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User u = new User();
        u.FirstName = 'test';
        u.LastName = 'test';
        u.Alias = 'ttest';
        u.Email = 'test@gmail.com';
        u.Username = 'test@gmail.com.stylam202204';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = pf.Id;
        INSERT u;

        PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = newPermission.Id;
        INSERT psa;

        system.runAs(u){
            
            
            Unit__c unit01 = new Unit__c();
            //unit01.Name = 'TestUnit01';
            
            unit01.Chargeable_Area__c = 1000;
          
            insert unit01;
            
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get('Person Account').getRecordTypeId();
            
            Account personAcct = new account();
            personAcct.lastName = 'ginny';
            personAcct.RecordTypeId = recordTypeId;
            insert personAcct;
            
            OpportunityWrapper oppWrap = new OpportunityWrapper();
            oppWrap.accountId = personAcct.id;
            oppWrap.name = 'TestOpp';
            oppWrap.closeDate = system.today() + 7;
            oppWrap.stageName = 'In Progress';
            
            ConvertAndUpsertOpportunity.Request reqOpp = new ConvertAndUpsertOpportunity.Request();
            reqOpp.opportunityWrap = oppWrap;
            List<ConvertAndUpsertOpportunity.Response> responseList = new List<ConvertAndUpsertOpportunity.Response>();
            responseList = ConvertAndUpsertOpportunity.execute(new List<ConvertAndUpsertOpportunity.Request>{reqOpp});
            
            Map<String, Object> shortUnit01Map = new Map<String, Object>();
            shortUnit01Map.put('Status__c','Booked');
            shortUnit01Map.put('Unit__c',unit01.id);
            shortUnit01Map.put('Opportunity__c',responseList[0].recordId);

            Shortlisted_Unit__c shortUnit01 = (Shortlisted_Unit__c) JSON.deserialize(
                JSON.serialize(shortUnit01Map), 
                Shortlisted_Unit__c.class
            );

            insert shortUnit01;
            
          
            
            CheckAndLinkUnit.Request request = new CheckAndLinkUnit.Request();
            request.opportunityId = responseList[0].recordId;
            request.shortListUnitId = shortUnit01.Id;
            request.bundleNo = 1;
          
            List<CheckAndLinkUnit.Request> requestList = new List<CheckAndLinkUnit.Request>();
            requestList.add(request);

            Test.startTest();
            List<String> errorList = CheckAndLinkUnit.execute(requestList);
            Test.stopTest();

            System.assertEquals(0, errorList.size());
        }
    }

    @isTest
    static void testExecute_ExistingUnitBundle() {

        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User u = new User();
        u.FirstName = 'test';
        u.LastName = 'test';
        u.Alias = 'ttest';
        u.Email = 'test@gmail.com';
        u.Username = 'test@gmail.com.stylam202204';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = pf.Id;
        INSERT u;

        PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = newPermission.Id;
        INSERT psa;

        system.runAs(u){
		  Unit__c unit01 = new Unit__c();
//            unit01.Name = 'TestUnit01';
  			unit01.Chargeable_Area__c = 1000;
   			insert unit01;
            Unit__c unit02 = new Unit__c();
            //unit02.Name = 'TestUnit02';
            
           
           unit01.Chargeable_Area__c = 1000;
            
          
            insert unit02;
            
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get('Person Account').getRecordTypeId();
            
            Account personAcct = new account();
            personAcct.lastName = 'ginny';
            personAcct.RecordTypeId = recordTypeId;
            insert personAcct;
            
            OpportunityWrapper oppWrap = new OpportunityWrapper();
            oppWrap.accountId = personAcct.id;
            oppWrap.name = 'TestOpp';
            oppWrap.closeDate = system.today() + 7;
            oppWrap.stageName = 'In Progress';
            
            ConvertAndUpsertOpportunity.Request reqOpp = new ConvertAndUpsertOpportunity.Request();
            reqOpp.opportunityWrap = oppWrap;
            List<ConvertAndUpsertOpportunity.Response> responseList = new List<ConvertAndUpsertOpportunity.Response>();
            responseList = ConvertAndUpsertOpportunity.execute(new List<ConvertAndUpsertOpportunity.Request>{reqOpp});
            
            Map<String, Object> shortUnit01Map = new Map<String, Object>();
            shortUnit01Map.put('Status__c','Booked');
            shortUnit01Map.put('Unit__c',unit01.id);
            shortUnit01Map.put('Opportunity__c',responseList[0].recordId);

            Shortlisted_Unit__c shortUnit01 = (Shortlisted_Unit__c) JSON.deserialize(
                JSON.serialize(shortUnit01Map), 
                Shortlisted_Unit__c.class
            );

            insert shortUnit01;
            
            
            
            Map<String, Object> shortUnit02Map = new Map<String, Object>();
            shortUnit02Map.put('Status__c','Booked');
            shortUnit02Map.put('Unit__c',unit02.id);
            shortUnit02Map.put('Opportunity__c',responseList[0].recordId);

            Shortlisted_Unit__c shortUnit02 = (Shortlisted_Unit__c) JSON.deserialize(
                JSON.serialize(shortUnit02Map),  
                Shortlisted_Unit__c.class
            );

            insert shortUnit02;
            
            List<Map<String,Object>> addCharges = new List<Map<String,Object>>();
            Map<String,Object> addCharge = new Map<String,Object>();
           
            addCharge.put('Name',unit01.Name);
          
            addCharge.put('Quantity',5);
            addCharge.put('Allow_Multiple__c',true);
            addCharges.add(addCharge);
            
            Map<String, Object> unitBundleMap = new Map<String, Object>();
            unitBundleMap.put('Additional_Charges__c',JSON.serialize(addCharges));
            unitBundleMap.put('Linked_Unit__c','["' + shortUnit02.id + '"]');
            unitBundleMap.put('Opportunity__c',responseList[0].recordId);
            unitBundleMap.put('Number_Of_Base_Units__c',1);
            unitBundleMap.put('Name','TestUnitBundle');

            Unit_Bundle__c unitBundle = (Unit_Bundle__c) JSON.deserialize(
                JSON.serialize(unitBundleMap), 
                Unit_Bundle__c.class
            );

            insert unitBundle;

            CheckAndLinkUnit.Request request = new CheckAndLinkUnit.Request();
            request.opportunityId = responseList[0].recordId;
            request.shortListUnitId = shortUnit01.Id;
            request.unitBundle = unitBundle;
            request.bundleNo = 1;

            List<CheckAndLinkUnit.Request> requestList = new List<CheckAndLinkUnit.Request>{request};

            Test.startTest();
            List<String> errors = CheckAndLinkUnit.execute(requestList);
            Test.stopTest();

            System.assertEquals(0, errors.size());
            Unit_Bundle__c updatedUnitBundle = [SELECT Id, Linked_Unit__c, Number_Of_Base_Units__c FROM Unit_Bundle__c WHERE Id = :unitBundle.Id];
          
        }
    }
}