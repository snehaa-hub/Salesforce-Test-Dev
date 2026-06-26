/**
 * @description This class is used to rollup field values to parent object
 */
public with sharing class RollupFields {
    /**
     * @description This is invocable method used to rollup field values to parent objec
     * @param requestLst
     */
    @InvocableMethod(label='Rollup Fields')
    public static void execute(List<Request> requestLst) {
        RollupFields.updateRollups(JSON.serialize(requestLst));
    }

    /**
     * @description This is future method used to rollup field values to parent objec
     * @param reqStr
     */
    @future
    public static void updateRollups(String reqStr) {
        List<Request> requestLst = (List<RollupFields.Request>) JSON.deserialize(
            reqStr,
            List<RollupFields.Request>.class
        );

        String soql =
            'SELECT COUNT(Id), ' +
            String.escapeSingleQuotes(requestLst[0].rollupFunction) +
            '(' +
            String.escapeSingleQuotes(requestLst[0].rollupFieldApiName) +
            '), ' +
            String.escapeSingleQuotes(requestLst[0].lookupFieldApiName) +
            ' FROM ' +
            String.escapeSingleQuotes(requestLst[0].rollupObjectApiName);

        soql += ' WHERE ';
        if (requestLst[0].filter != '' && requestLst[0].filter != null) {
            soql += '(' + requestLst[0].filter + ') AND ';
        }

        Set<String> recordIds = new Set<String>();

        for (Request req : requestLst) {
            recordIds.add(req.recordId);
            if (req.priorRecordId != null && req.priorRecordId != '') {
                recordIds.add(req.priorRecordId);
            }
        }

        soql += requestLst[0].lookupFieldApiName + ' IN:recordIds';
        soql += ' GROUP BY ' + requestLst[0].lookupFieldApiName;

        List<AggregateResult> result = Database.query(soql);

        List<SObject> sObjLst = new List<SObject>();
        Map<String, AggregateResult> recordIdMap = new Map<String, AggregateResult>();

        for (AggregateResult ar : result) {
            String recordId = (String) ar.get(requestLst[0].lookupFieldApiName);

            recordIdMap.put(recordId, ar);
        }

        for (Id recordId : recordIds) {
            SObject sObj = ((Id) recordId).getSObjectType().newSObject(recordId);
            if (recordIdMap.containsKey(recordId)) {
                sObj.put(requestLst[0].fieldToUpdate, recordIdMap.get(recordId).get('expr1'));
            } else {
                sObj.put(requestLst[0].fieldToUpdate, 0);
            }

            sObjLst.add(sObj);
        }
        if(!test.isRunningTest()){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                        AccessType.UPDATABLE, sObjLst);

            if(!(securityDecision.getRecords()).isEmpty()){
                update securityDecision.getRecords();
            }
        }
    }

    /**
     * @description Request wrapper that input values required to rollup field
     */
    public class Request {
        @InvocableVariable(label='Field to update Api Name' required=true)
        public String fieldToUpdate;

        @InvocableVariable(label='Rollup Field Api Name' required=true)
        public String rollupFieldApiName;

        @InvocableVariable(label='Lookup Field Api Name' required=true)
        public String lookupFieldApiName;

        @InvocableVariable(label='Rollup Object Api Name' required=true)
        public String rollupObjectApiName;

        @InvocableVariable(label='Lookup Object Api Name' required=true)
        public String lookupObjectApiName;

        @InvocableVariable(label='Rollup Function' required=true)
        public String rollupFunction;

        @InvocableVariable(label='Filter' required=false)
        public String filter;

        @InvocableVariable(label='RecordId' required=true)
        public String recordId;

        @InvocableVariable(label='Prior RecordId' required=false)
        public String priorRecordId;
    }
}