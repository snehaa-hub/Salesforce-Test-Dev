/**
* @description This class is a helper class to create enquiry from api 
*/
public without sharing class EnquiryService {
    
    /**
* @description This method is used to create enquiry
* @param request
* @return enquiry response
*/
    public static EnquiryRestService.EnquiryResponse createEnquiry(EnquiryRestService.EnquiryRequest request) {
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(System.Label.Person_Account_RecordType_Name)
            .getRecordTypeId();
        EnquiryRestService.EnquiryResponse response = new EnquiryRestService.EnquiryResponse();
        
        Map<String, String> validateCheck = validateValues(
            request.contactMap
        );
        
        if (validateCheck.isEmpty() && validateCheck.size() <= 0) {
            List<Account> accountList = new List<Account>();
            List<Enquiry__c> enquiryList = new List<Enquiry__c>();
            Set<String> emailSet = new Set<String>();
            Set<String> phoneSet = new Set<String>();
            
            emailSet.add(request.contactMap.get('PersonEmail'));
            phoneSet.add(request.contactMap.get('PersonMobilePhone'));
            
            Account accountObject = new Account();
            for (String contctString : request.contactMap.keySet()) {
                accountObject.put(contctString, request.contactMap.get(contctString));
            }
            accountObject.RecordTypeID = personAccountId;
            accountList.add(accountObject);
            
            Enquiry__c enquiryObject = new Enquiry__c();
            for (String enqString : request.enquiryMap.keySet()) {
               System.debug('enqString'+enqString);
                if(enqString.contains('intentType'))
                {
                    system.debug('Yes');
                    String enquiryRecordTypeName = String.Valueof(request.enquiryMap.get(enqString));
                    Id enquiryRecordTypeId = Schema.SObjectType.Enquiry__c.getRecordTypeInfosByName()
                        .get(enquiryRecordTypeName)
                        .getRecordTypeId();
                    System.debug('enquiryRecordTypeId'+enquiryRecordTypeId);
                    enquiryObject.put('RecordTypeId', enquiryRecordTypeId);
                }
                else
                {
                    String objectName = 'Enquiry__c';
                    String fieldName = enqString;
                    
                    Schema.DisplayType enquiryField = Schema.getGlobalDescribe()
                        .get(objectName)
                        .getDescribe()
                        .fields
                        .getMap()
                        .get(fieldName)
                        .getDescribe()
                        .getType();
                    system.debug('(request.enquiryMap.get(enqString))'+(request.enquiryMap.get(enqString)));
                    System.debug('string.valueof(enquiryField)'+string.valueof(enquiryField) );
                    if (string.valueof(enquiryField) == 'DATETIME') {
                        enquiryObject.put(enqString, Datetime.valueof(request.enquiryMap.get(enqString)));
                    } else if (string.valueof(enquiryField) == 'DATE') {
                        enquiryObject.put(enqString, Date.valueof(request.enquiryMap.get(enqString)));
                    }
                    else if(string.valueof(enquiryField) == 'INTEGER')
                    {
                         enquiryObject.put(enqString, Integer.valueof(request.enquiryMap.get(enqString)));
                    }
                     else if(string.valueof(enquiryField) == 'DOUBLE')
                    {
                         enquiryObject.put(enqString, decimal.valueof(request.enquiryMap.get(enqString)));
                    }
                    
                    
                    else {
                        enquiryObject.put(enqString, request.enquiryMap.get(enqString));
                    }
                }
            }
            
            enquiryObject.Mobile__c = request.contactMap.get('PersonMobilePhone');
            enquiryObject.Email__c = request.contactMap.get('PersonEmail');
            
            Boolean gotError = false;
            if (String.isBlank(enquiryObject.Id)) {
                enquiryList.add(enquiryObject);
                
                List<Enquiry__c> enquiryToBeInserted = new List<Enquiry__c>();
                enquiryToBeInserted = EnquiryService.searchAccountAndLinkEnquiry(
                    accountList,
                    enquiryList
                );
                
                if (!enquiryToBeInserted.isEmpty()) {
                    Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Enquiry__c;
                    Boolean thisUserMayUpdate = drSObj.isCreateable();
                    SObjectAccessDecision securityDecision = Security.stripInaccessible(
                        AccessType.CREATABLE,  enquiryToBeInserted);
                    
                    if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
                        Database.DMLOptions dml = new Database.DMLOptions(); 
                        dml.DuplicateRuleHeader.AllowSave = true;
                        
                        for(Enquiry__c enq: (List<Enquiry__c>) securityDecision.getRecords()){
                            Database.SaveResult sr = Database.insert(enq, dml);
                            
                            if(sr.isSuccess() == false){
                                gotError = true;
                                
                                Map<String, String> errorMap = new Map<String, String>();
                                String errorMessage;
                                for(Database.Error err : sr.getErrors()) {
                                    if(!String.isBlank(errorMessage)){
                                        errorMessage = errorMessage + ', '+ err.getMessage();
                                    }else{
                                        errorMessage = err.getMessage();
                                    }
                                }
                                
                                response.status = System.Label.Error_Status_Enquiry_Api;
                                response.errorMessage = errorMap;
                            }
                            
                            if(sr.getId() != null){
                                enquiryObject.Id = sr.getId();
                            }
                        }
                        
                        if(gotError == false){
                            List<Enquiry__c> enquiryListQueried = [SELECT Id, Name,
                                                                   Site_Visit_Location__c,
                                                                   Site_Visit_Date__c,
                                                                   Contact_Person__c
                                                                   FROM Enquiry__c
                                                                   WHERE Id =: enquiryObject.Id
                                                                  ];
                            CheckAndCreateSiteVisit(enquiryListQueried);
                        }
                    }
                }
                
            } else {
                Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Enquiry__c;
                Boolean thisUserMayUpdate = drSObj.isUpdateable();
                SObjectAccessDecision securityDecision = Security.stripInaccessible(
                    AccessType.UPDATABLE,  new List<Enquiry__c>{enquiryObject});
                
                if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
                    update securityDecision.getRecords();
                    
                    CheckAndCreateSiteVisit((List<Enquiry__c>) securityDecision.getRecords());
                }
            }
            
            if(gotError == false){
                response.status = System.Label.Success_Status_Enquiry_Api;
                response.enquiryData = enquiryObject;
            }
        } else {
            response.status = System.Label.Error_Status_Enquiry_Api;
            response.errorMessage = validateCheck;
        }
        
        return response;
    }
    
    /**
* @description This method is used to validate mandatory fields for contact details
* @param contactMap
* @return errorMessageList
*/
    public static Map<String, String> validateValues( Map<String, String> contactMap) {
        Map<String, String> errorMessageList = new Map<String, String>();
        
        FieldSetInfo.FieldSet fieldSets = FieldSetInfo.getFieldSet('','Account','MandatoryFieldsEnquiryApi');
        List<String> fieldlist = new List<String>();
        for(FieldSetInfo.Fields field: fieldSets.Fields){
            if(contactMap.get(field.apiName) == null){
                fieldlist.add(field.label);
            }
        }
        
        if(!fieldlist.isEmpty()){
            errorMessageList.put(System.Label.Mandatory_Field_Message, String.join(fieldlist, ','));
        }
        
        return errorMessageList;
    }
    
    /**
* @description This method is used to check duplicate account and link it with enquiry
* @param accountList
* @param enquiryList
* @return list of enquiry
*/
    public static List<Enquiry__c> searchAccountAndLinkEnquiry(
        List<Account> accountList,
        List<Enquiry__c> enquiryList
    ) {
        List<Enquiry__c> enquiryToBeInserted = new List<Enquiry__c>();
        
        if (!accountList.isEmpty()) {
            List<Account> accountToBeInserted = new List<Account>();
            Map<String, Account> phoneMap = new Map<String, Account>();
            Map<String, Account> emailMap = new Map<String, Account>();
            
            for(Account acc: accountList){
                CheckDuplicate.Request req = new CheckDuplicate.Request();
                req.record = acc;
                
                for(CheckDuplicate.Response res: CheckDuplicate.execute(new List<CheckDuplicate.Request>{ req } )){
                    if(!String.isBlank(res.duplicateRecordId)){
                        acc.Id = res.duplicateRecordId;
                        if (!String.isBlank(acc.PersonMobilePhone)) {
                            phoneMap.put(acc.PersonMobilePhone, acc);
                        }
                        if (!String.isBlank(acc.PersonEmail)) {
                            emailMap.put(acc.PersonEmail, acc);
                        }
                    }else{
                        accountToBeInserted.add(acc);
                    }
                } 
            }
            
            if(!accountToBeInserted.isEmpty()){
                Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Account;
                Boolean thisUserMayUpdate = drSObj.isCreateable();
               
                
                if(thisUserMayUpdate){
                     SObjectAccessDecision securityDecision = Security.stripInaccessible(
                    AccessType.CREATABLE,  accountToBeInserted);
                    insert securityDecision.getRecords();
                    if(!(securityDecision.getRecords()).isEmpty()){
                    for (Account acc : (List<Account>) securityDecision.getRecords()) {  //(List<Account>) securityDecision.getRecords()
                        if (!String.isBlank(acc.PersonMobilePhone)) {
                            phoneMap.put(acc.PersonMobilePhone, acc);
                        }
                        if (!String.isBlank(acc.PersonEmail)) {
                            emailMap.put(acc.PersonEmail, acc);
                        }
                    }
                }
                }
            }
            
            if (!enquiryList.isEmpty()) {
                for (Enquiry__c enquiry : enquiryList) {
                    if (emailMap.containskey(enquiry.Email__c)) {
                        enquiry.Contact_Person__c = emailMap.get(enquiry.Email__c)?.Id;
                        enquiry.Name = setEnquiryName(emailMap,enquiry.Email__c);
                    }
                    
                    if (enquiry.Contact_Person__c == null || Test.isRunningTest()) {
                        if (phoneMap.containskey(enquiry.Mobile__c)) {
                            enquiry.Contact_Person__c = phoneMap.get(enquiry.Mobile__c)?.Id;
                            enquiry.Name = setEnquiryName(phoneMap,enquiry.Mobile__c);
                        }else if(emailMap.containskey(enquiry.Email__c)){
                            enquiry.Contact_Person__c = phoneMap.get(enquiry.Email__c)?.Id;
                            enquiry.Name = setEnquiryName(phoneMap,enquiry.Email__c);
                        }
                    }
                    
                    enquiry.Created_From__c = System.Label.Created_From_API;
                    enquiry.OwnerId = Test.isRunningTest()?UserInfo.getUserId():BuildeOpedia_Configuration__mdt.getInstance('DefaultEnquiryOwner').value__c;
                    enquiryToBeInserted.add(enquiry);
                }
            }
        }
        return enquiryToBeInserted;
    }
    
    /**
* @description This method is used to set enquiry in a specific format
* @param accountMap
* @param key
* @return String(enquiry name)
*/
    public static String setEnquiryName(Map<String, Account> accountMap, String key){
        String enquiryName;
        
        if(!String.isBlank(accountMap.get(key).Salutation)){
            enquiryName = accountMap.get(key).Salutation;
        }
        
        if(!String.isBlank(accountMap.get(key).FirstName)){
            if(!String.isBlank(enquiryName)){
                enquiryName = enquiryName + ' ' + accountMap.get(key).FirstName;
            }else{
                enquiryName = accountMap.get(key).FirstName;
            }
        }
        
        if(!String.isBlank(enquiryName)){
            enquiryName = enquiryName + ' ' + accountMap.get(key).LastName;
        }else{
            enquiryName = accountMap.get(key).LastName;
        }
        
        return enquiryName;
    }
    
    /**
* @description This method is used to create site visit record with respect to enquiry
* @param enquiryList
*/
    public static void CheckAndCreateSiteVisit( List<Enquiry__c> enquiryList ){
        if(!enquiryList.isEmpty()){
            
            List<Site_Visit__c> siteVisitToBeInserted = new List<Site_Visit__c>();
            Set<Id> siteVisitLocationSet = new Set<Id>();
            
            for(Enquiry__c enq: enquiryList){
                if(enq.Site_Visit_Location__c != null){
                    siteVisitLocationSet.add(enq.Site_Visit_Location__c);
                }
            }
            
            Map<Id,String> siteVisitLocationMap = new Map<Id,String>();
            SObjectAccessDecision decisionBusinessHours = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Id, Name
                 FROM BusinessHours 
                 WHERE Id In: siteVisitLocationSet]);
            
            if(!(decisionBusinessHours.getRecords()).isEmpty()) {
                for(BusinessHours bhs: (List<BusinessHours>) decisionBusinessHours.getRecords()){
                    siteVisitLocationMap.put(bhs.Id,bhs.Name);
                }
            }
            
            Set<Id> enquiryIds = new Set<Id>();
            for(Enquiry__c enq: enquiryList){
                if(enq.Site_Visit_Date__c != null){
                    Site_Visit__c siteVisit = new Site_Visit__c();
                    
                    String siteVisitName = enq.Name;
                    
                    if(enq.Site_Visit_Location__c != null){
                        siteVisit.Sales_Office__c = enq.Site_Visit_Location__c;
                        siteVisitName = siteVisitName + '-' + siteVisitLocationMap.get(enq.Site_Visit_Location__c);
                    }
                    
                    siteVisitName = siteVisitName + '-' + enq.Site_Visit_Date__c.format('dd-MM-yyyy HH:mm:ss');
                    
                    siteVisit.Enquiry__c = enq.Id;
                    siteVisit.Account__c = enq.Contact_Person__c;
                    siteVisit.Visit_Date_Time__c = enq.Site_Visit_Date__c;
                    siteVisit.Status__c = 'Scheduled';
                    siteVisit.Created_From__c = System.Label.Created_From_API;
                    siteVisit.Name = siteVisitName;
                    siteVisit.Create_Event__c = true;
                    siteVisitToBeInserted.add(siteVisit);
                    
                    enquiryIds.add(enq.Id);
                }
            }
            
            if(!enquiryIds.isEmpty()){
                List<Site_Visit__c> siteVisitToBeUpdated = new List<Site_Visit__c>();
                SObjectAccessDecision decisionSiteVisit = Security.stripInaccessible(
                    AccessType.READABLE,
                    [ SELECT 
                     Id, 
                     Status__c 
                     FROM Site_Visit__c 
                     WHERE Enquiry__c =: enquiryIds
                     AND Status__c = 'Scheduled']);
                
                if(!(decisionSiteVisit.getRecords()).isEmpty()) {
                    for(Site_Visit__c siteVisit: (List<Site_Visit__c>) decisionSiteVisit.getRecords()){
                        
                        siteVisit.Status__c = 'Deferred';
                        siteVisit.Deferred_Reason__c = 'Rescheduled';
                        siteVisitToBeUpdated.add(siteVisit);
                    }
                }
                
                if(!siteVisitToBeUpdated.isEmpty()){
                    Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Site_Visit__c;
                    Boolean thisUserMayUpdate = drSObj.isUpdateable();
                    SObjectAccessDecision securityDecision = Security.stripInaccessible(
                        AccessType.UPDATABLE,  siteVisitToBeUpdated);
                    
                    if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
                        insert securityDecision.getRecords();
                    }
                }
            }
            
            if(!siteVisitToBeInserted.isEmpty()){
                Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Site_Visit__c;
                Boolean thisUserMayUpdate = drSObj.isCreateable();
                SObjectAccessDecision securityDecision = Security.stripInaccessible(
                    AccessType.CREATABLE,  siteVisitToBeInserted);
                
                if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
                    insert securityDecision.getRecords();
                }
            }
        }
    }
public static void CreateRelatedOpportunity(List<Enquiry__c> enquiryList) {
    List<Opportunity__c> oppToInsert = new List<Opportunity__c>();
    
    System.debug('Input Enquiry List: ' + enquiryList);

    for (Enquiry__c enq : enquiryList) {
        System.debug('Checking Enquiry: ' + enq);
        
        if (enq.Status__c == 'Closed' && enq.Reason_for_Closed__c == 'Qualified') {
            Opportunity__c opp = new Opportunity__c();
            opp.Name = enq.Name;
            opp.Stage__c = 'Qualified';
            oppToInsert.add(opp);
            System.debug('Opportunity prepared: ' + opp);
        }
    }
    
    if (!oppToInsert.isEmpty()) {
        insert oppToInsert;
        System.debug('Opportunities inserted: ' + oppToInsert);
    } else {
        System.debug('No Opportunities to insert.');
    }
}

}