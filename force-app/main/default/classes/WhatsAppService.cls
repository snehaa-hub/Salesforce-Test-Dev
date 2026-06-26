public with sharing class WhatsAppService {

    @InvocableMethod(label='Send WhatsApp Message')
    public static void sendMessage(List<Request> requests) {
        
        for(Request reqData : requests){
            sendAsync(reqData.phone);
        }
    }

    @future(callout=true)
    public static void sendAsync(String phone){

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint('https://graph.facebook.com/v19.0/1020953204442225/messages');
        req.setMethod('POST');

        req.setHeader('Authorization', 'Bearer EAANwfecFzEgBRSU7PCsfTK5AxPuCEv0RSmk0iZC8mvJNpSIThhJoSI1dGTNp7K78y17HYZCV85alPrSHz3HoJiAsz6DfO4ShL1Yex8ZCJ8KdCjoJM6ZBY2ZAEtSa9sS9ZBcCYeVTl8pXZC5w036xmWsKERXiGCQn5sKi6JxtZCcmLVt5c2sfLUmZA0FfDr2DkJwZDZD');
        req.setHeader('Content-Type', 'application/json');

        String body = JSON.serialize(new Map<String, Object>{
            'messaging_product' => 'whatsapp',
            'to' => phone,
            'type' => 'template',
            'template' => new Map<String, Object>{
                'name' => 'enquiry_saved',
                'language' => new Map<String, String>{
                    'code' => 'en_US'
                }
            }
        });

        req.setBody(body);

        HttpResponse res = http.send(req);
        System.debug('Response: ' + res.getBody());
    }

    public class Request {
        @InvocableVariable(required=true)
        public String phone;
    }
}