/**
 * @description This class is used to set booking name dynamically according to format specified
 */
public with sharing class SetBookingName {

    /**
     * @description This is invocable method used to set booking name dynamically according to format specified
     * @param requestLst
     */
    @InvocableMethod(label='Set Booking Name' description='Set Booking Name')
    public static void execute(List<Request> requestLst){
        if(!requestLst.isEmpty()){
            Set<Id> bookingIds = new Set<Id>();
            for(Request req : requestLst){ 
                bookingIds.add(req.bookingId);
            }

            Set<String> fieldsToQuery = new Set<String>();

            if(!getFields('Booking_No_Prefix').isEmpty()){
                fieldsToQuery.addall(getFields('Booking_No_Prefix'));
            }
            
            if(!getFields('Booking_No_Suffix').isEmpty()){
                fieldsToQuery.addall(getFields('Booking_No_Suffix'));
            }

            fieldsToQuery.add('Id');
            fieldsToQuery.add('Booking_No__c');

            if(!fieldsToQuery.isEmpty() && !bookingIds.isEmpty()){
                String fields = String.join(new List<String>(fieldsToQuery), ',');
                String query = 'SELECT ' + String.escapeSingleQuotes(fields) + ' FROM Booking__c  WHERE Id In :bookingIds';
            
                if(!String.isBlank(query)){
                    List<Booking__c> bookinglist = new List<Booking__c>();

                    for(SObject sObj: Database.query(query)){
                        Map<String, Object> fieldsToValueMap = new Map<String, Object>();
                        fieldsToValueMap.putAll(SetBookingName.generateFieldValueMap(sObj.getPopulatedFieldsAsMap(), ''));

                        String bookingName;
                        try{
                            String bookingPrefix = BuildeOpedia_Configuration__mdt.getInstance('Booking_No_Prefix').value__c;
                            Pattern p = Pattern.compile('\\{'+'\\{'+'(.*?)\\}}');
                            Matcher matcher = p.matcher(bookingPrefix);
                            while(matcher.find()) {
                                String value = '';

                                String mergeFieldName = matcher.group().substring( 2, matcher.group().length() - 2);

                                if(mergeFieldName == 'Year'){
                                    value = String.valueof(system.today().year());
                                }else if(mergeFieldName == 'Date'){
                                    value = String.valueof(system.now().format('dd-MM-yyyy'));
                                }else{
                                    if(fieldsToValueMap.containskey(mergeFieldName)){
                                        value = String.valueof(fieldsToValueMap.get(mergeFieldName));
                                    }
                                }
                                String regexToReplace = '\\{'+'\\{'+ mergeFieldName +'(.*?)\\}}';
                                bookingPrefix = (bookingPrefix).replaceAll(regexToReplace, value);
                            }

                            bookingName = bookingPrefix + String.valueof(fieldsToValueMap.get('Booking_No__c'));
                        }catch(Exception e){
                            bookingName = String.valueof(fieldsToValueMap.get('Booking_No__c'));
                        }                       
                        
                        try{
                            String bookingSuffix = BuildeOpedia_Configuration__mdt.getInstance('Booking_No_Suffix').value__c;

                            Pattern p = Pattern.compile('\\{'+'\\{'+'(.*?)\\}}');
                            Matcher matcher = p.matcher(bookingSuffix);
                            while(matcher.find()) {
                                String value = '';
                                String mergeFieldName = matcher.group().substring( 2, matcher.group().length() - 2);
                                if(mergeFieldName == 'Year'){
                                    value = String.valueof(system.today().year());
                                }else if(mergeFieldName == 'Date'){
                                    value = String.valueof(system.now().format('dd-MM-yyyy'));
                                }else{
                                    if(fieldsToValueMap.containskey(mergeFieldName)){
                                        value = String.valueof(fieldsToValueMap.get(mergeFieldName));
                                    }
                                }
                                String regexToReplace = '\\{'+'\\{'+ mergeFieldName +'(.*?)\\}}';

                                bookingSuffix = (bookingSuffix).replaceAll(regexToReplace, value);

                                bookingName = bookingName + bookingSuffix;
                            }
                        }catch(Exception e){
                            //throw new AuraHandledException(e.getMessage());
                        }  

                        Booking__c booking = new Booking__c();
                        booking.Id = String.valueof(fieldsToValueMap.get('Id'));
                        booking.Name = bookingName;
                        bookinglist.add(booking);
                    }

                    if(!bookinglist.isEmpty()){
                        Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Booking__c;
                        Boolean thisUserMayUpdate = drSObj.isUpdateable();
                        SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                                    AccessType.UPDATABLE, bookinglist);
    
                        if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
                            update securityDecision.getRecords();
                        }
                    }
                }
            }       
        }
    }
    
    /**
     * @description This is used to get variables used in format specified
     * @param metaDataUsed
     * @return list of variables(fields)
     */
    public static  List<String> getFields(String metaDataUsed){
        List<String> fieldsToQuery = new List<String>();
        try{
            String bookingSuffix = BuildeOpedia_Configuration__mdt.getInstance(metaDataUsed).value__c;
            
            Pattern p = Pattern.compile('\\{'+'\\{'+'(.*?)\\}}');
            Matcher matcher = p.matcher(bookingSuffix);
            while(matcher.find()) {
                String mergeFieldName = matcher.group().substring( 2, matcher.group().length() - 2);
                if(mergeFieldName != 'Year' && mergeFieldName != 'Date'){
                    fieldsToQuery.add(mergeFieldName);
                }
            }
            return fieldsToQuery;
        }catch(Exception e){
            return fieldsToQuery;
        } 
    }
    
    /**
     * @description Method to set data in form of map with field in booking format and their value
     * @param fieldValues
     * @param fieldUsed
     * @return Map<String, Object> field Name and value
     */
    public static Map<String, Object> generateFieldValueMap(Map<String, Object> fieldValues, String fieldUsed){

        Map<String, Object> fieldsToValueMap = new Map<String, Object>(); 
        for (String fieldName : fieldValues.keySet()) {
			String formatedFieldUsed;
            if(String.isBlank(fieldUsed)){
                formatedFieldUsed = fieldName;
            }else{
                formatedFieldUsed = fieldUsed+'.'+fieldName;
            }

            if (fieldValues.get(fieldName) instanceof sObject) {
                sObject obj = (sObject) fieldValues.get(fieldName);

                fieldsToValueMap.putAll(SetBookingName.generateFieldValueMap(obj.getPopulatedFieldsAsMap(),formatedFieldUsed));
            } else {

                fieldsToValueMap.put(formatedFieldUsed,fieldValues.get(fieldName));
            }
        }

        return fieldsToValueMap;
    }
    
    /**
     * @description Request wrapper that input booking record id
     */
    public class Request{
        @InvocableVariable(label = 'Booking Id' description = 'Id of Booking' required = true)
        public String bookingId;
    }
}