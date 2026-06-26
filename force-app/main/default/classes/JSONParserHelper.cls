public with sharing class JSONParserHelper {

    @InvocableMethod(label='Parse Unit Ids')
    public static List<Id> parseIds(List<String> jsonList){

        List<Id> result = new List<Id>();

        for(String jsonStr : jsonList){

            if(String.isBlank(jsonStr)) continue;

            List<Object> raw = (List<Object>) JSON.deserializeUntyped(jsonStr);

            for(Object obj : raw){
                result.add((Id)obj);
            }
        }

        return result;
    }
}