/**
* @File Name : testcallout.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : August 1, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 1, 2025 |   | Initial Version
**/


@RestResource(urlMapping = '/whatsappwebhooks/*')
// whatsapp/anit/vi
global class WhatsAppWebhook {
	private static Final String SIGNATURE_VALID_MESSAGE = 'Signature Verified';
	private static Final String SIGNATURE_NOT_VALID_MESSAGE = 'Signature could not be verified';
		@HttpGet 
		global static void doGet() {
		RestResponse response =RestContext.response;
		RestRequest request =RestContext.request;
		if(request.params.get('hub.verify_token') == 'WHATSAPPTOKEN') {
		response.responseBody = Blob.valueOf(request.params.get('hub.challenge'));
		}
}
}