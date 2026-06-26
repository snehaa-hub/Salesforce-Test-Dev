/**
 * @description This class is used as api for enquiry
 */
@RestResource(urlMapping='/enquiry/*')
global without sharing class EnquiryRestService {

    /**
     * @description This is post api call method
     * @return EnquiryResponse 
     */
    @HttpPost
    global static EnquiryResponse doPost() {
        String enqJSON = RestContext.request.requestBody.toString();
        EnquiryRequest request = (EnquiryRequest) (JSON.deserialize(enqJSON, EnquiryRequest.class));
        EnquiryResponse enqResponse;
        
        DataSyncService dataSync = new DataSyncService();
        dataSync.initialize(enqJSON, System.Label.Enquiry_API_Event_Type, System.Label.InboundSyncDirection);
        
        try{
            enqResponse = EnquiryService.createEnquiry(request);
           
            if(enqResponse.status == System.Label.Success_Status_Enquiry_Api){
                dataSync.success(JSON.serialize(enqResponse));
            }else{
                dataSync.error(JSON.serialize(enqResponse));
            }
        }catch(Exception ex){
            dataSync.error('ErrorMessage: '+ ex.getMessage()+'. Error Line Number: ' + ex.getLineNumber());
        }
        
        return enqResponse;
    }
    
    /**
     * @description This is request wrapper for enquiry api 
     */
    global class EnquiryRequest {
        global Map<String, String> enquiryMap;
        global Map<String, String> contactMap;
    }
    
    /**
     * @description This is response wrapper for enquiry api 
     */
    global class EnquiryResponse {
        global Enquiry__c enquiryData;
        global String status;
        /**
         * @description variable that is used to set error message
         */
        global Map<String, String> errorMessage { get; set; }
    }
}