trigger opportunityStageMove on Opportunity__c (before insert,before update) {
  for(Opportunity__c opp: Trigger.New){
        if(opp.Agreement_Uploaded__c == true && opp.Stage__c == 'Agreement'){
            opp.Stage__c ='Payment';
           
        }
    }
    for(Opportunity__c opplist: Trigger.New){
       if( opplist.Amount_Received_from_Landlord__c != null && opplist.Amount_Received_from_Tenant__c != null
       && opplist.Payment_Received_Date__c != null && opplist.Payment_Received_From__c != null
       &&  opplist.Payment_Status__c  != null && opplist.Total_Amount_Received__c != null ){
              opplist.Stage__c = 'Closed Won' ;
          }
}
}