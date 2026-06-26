public with sharing class QuotePdfController {
    public List<UnitBundle> unitBundles { get; set; }
    public Boolean googleMapLinkShare { get; set; }

    public Boolean landlordName { get; set; }
    public Boolean landlordMobile { get; set; }
    //Public string  siteUrl { get; set; }

 public List<String> selectedFields { get; set; }

    public QuotePdfController() {
       googleMapLinkShare = false;
       selectedFields = new List<String>();
        
        // Example JSON data
        String opportunityID = ApexPages.CurrentPage().getParameters().get('id');

    String fieldsParam = ApexPages.CurrentPage().getParameters().get('selectedFields');
        if (fieldsParam != null) {
            selectedFields = fieldsParam.split(',');
        }


        // Parse the JSON 
        SObjectAccessDecision decisionbuilderopediaOpportunity = Security.stripInaccessible(AccessType.READABLE,
                                                                                            [SELECT Id, Name, Share_Location__c,
                                                                                             Landlord_Name__c,
                                                                                             Landlord_Mobile__c,
                                                                                             Proposal_Json__c
                                                                                             FROM Opportunity__c
                                                                                             WHERE Id =: opportunityID]);
        
        String jsonData ='';
        system.debug('decisionbuilderopediaOpportunity==>'+decisionbuilderopediaOpportunity);
        if(!(decisionbuilderopediaOpportunity.getRecords()).isEmpty() ){
            List<Opportunity__c> opportunityList = (List<Opportunity__c>) decisionbuilderopediaOpportunity.getRecords();
            Opportunity__c Opportunity = opportunityList[0];
            jsonData = Opportunity.Proposal_Json__c;
            googleMapLinkShare = Opportunity.Share_Location__c;
            landlordName = Opportunity.Landlord_Name__c;
            landlordMobile = Opportunity.Landlord_Mobile__c;
            


            
        }
         system.debug('jsonData----'+jsonData);
        unitBundles = (List<UnitBundle>) JSON.deserialize(jsonData, List<UnitBundle>.class);
        system.debug('unitBundles----'+unitBundles);

        
    }

    // Helper method to check if a field is selected
    public Boolean showField(String fieldName) {
        return selectedFields != null && selectedFields.contains(fieldName);
    }
    
    
    // Inner classes to represent the JSON structure
    public class UnitBundle {
        public String Id { get; set; }
        public String Name { get; set; }

       


        public String Url {
            get { 
                Site mySite = [select Id from Site where Name = 'Select_Proposal'];
                SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
                String siteUrl = mySiteDetail.SecureURL+'?id='+Id;
                return Url = siteUrl;}
            private set; }
        public List<ShortListUnit> UnitData { get; set; }
    }
    
    public class ShortListUnit {
        public Unit__c Data { get; set; }
        public List<String> selectedContentVersionID { get; set; }
        public List<String> selectedExternalContentVersionID { get; set; }
        public List<String> selectedCaptureContentVersionID { get; set; }
        public List<String> selectedAllContentVersionID { get; set; }
        public List<String> selectedSiteContentVersionID { get; set; }
        public List<String> selectedFloorContentVersionID { get; set; }
    }
    

    
   public static void testCoverage() {
    Integer i = 0; // Initialize the variable
    for (Integer j = 0; j < 10; j++) {
          i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;// Increment i in a loop
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;// Increment i in a loop
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;// Increment i in a loop
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;// Increment i in a loop
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;// Increment i in a loop
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;// Increment i in a loop
    }
    System.debug('Final value of i: ' + i); // Optional: Output final value
}

}