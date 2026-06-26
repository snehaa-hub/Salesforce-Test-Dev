@RestResource(urlMapping='/inboundLeads99Acres')
global with sharing class InboundLeadHandler {

    // Define the Lead Wrapper classes
    global class LeadWrapper {
        public List<LeadData> Leads;
    }

    global class LeadData {
        public String FirstName;
        public String LastName;
        public String Phone;
        public String Email;
        public String Project;
        public String Campaign;
        public String Source;
        public String Medium;
        public String Term;
        public String Content;
        public String Locality;
        public String BHK;
    }

    // REST POST Method
    @HttpPost
    global static String handleInboundLead() {
        // Read the request body
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        List<String> accIds = new List<String>();
		Set<String> accSetIds = new Set<String>();
        try {
            system.debug('request body : '+requestBody);
            // Deserialize the JSON into the wrapper class
            InboundLeadHandler.LeadWrapper wrapper = (InboundLeadHandler.LeadWrapper) JSON.deserialize(requestBody, InboundLeadHandler.LeadWrapper.class);
            List<Enquiry__c> leadsToInsert = new List<Enquiry__c>();

            // Loop through each lead and map to Lead object
            for (LeadData ld : wrapper.Leads) {
                Enquiry__c newLead = new Enquiry__c();
                newLead.Name = ld.FirstName + ld.LastName;
                newLead.Mobile__c = ld.Phone;
                newLead.Email__c = ld.Email;
                newLead.Enquiry_Source__c = 'Online'; // Required field
                newLead.Enquiry_Sub_Source__c = '99 Acres';

                // Optionally store additional fields in custom fields if available
                newLead.Comment__c = 'Campaign: ' + ld.Campaign + 
                                      ', Medium: ' + ld.Medium +
                                      ', Term: ' + ld.Term +
                                      ', Content: ' + ld.Content +
                                      ', Locality: ' + ld.Locality +
                                      ', BHK: ' + ld.BHK;

                leadsToInsert.add(newLead);
            }

            // Insert all leads
            if (!leadsToInsert.isEmpty()) {
                insert leadsToInsert;
                return 'Record Created Successfully';
            }
            

        } catch (Exception ex) {
            // Log error or throw for debugging
            System.debug('Error processing inbound lead: ' + ex.getMessage());
            
            //throw new AuraHandledException('Failed to process lead request.');
            return 'Failed to process lead request : '+ ex.getMessage();
        }
        return '';
    }
}