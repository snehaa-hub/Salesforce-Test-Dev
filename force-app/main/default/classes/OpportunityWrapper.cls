/**
 * @description This is wrapper class to set opportunity data
 */
global class OpportunityWrapper {
	@AuraEnabled
    global String Id;

	@AuraEnabled
    global String name;

    @AuraEnabled
    global Decimal amount;
    
    @AuraEnabled
    global String stageName;
    
    @AuraEnabled
    global String ownerId;
    
    @AuraEnabled
    global String accountId;
    
    @AuraEnabled
    global String projectId;
    
    @AuraEnabled
    global String enquiryId;
    
    @AuraEnabled
    global String channelPartnerAccountId;
    
    @AuraEnabled
    global String channelPartnerAgentId;
    
    @AuraEnabled
    global Date closeDate;
    
    @AuraEnabled
    global String budgetRange;
    
    @AuraEnabled
    global String enquirySource;
    
    @AuraEnabled
    global String enquirySubSource;
    
    @AuraEnabled
    global String natureOfPurchase;
    
    @AuraEnabled
    global String typeOfUnit;
    
    @AuraEnabled
    global String sourceOfFinance;
    
    @AuraEnabled
    global String unitCategory;

    @AuraEnabled
    global Integer unitBundleNo;

    @AuraEnabled
    global DateTime lastActivityDate;
}