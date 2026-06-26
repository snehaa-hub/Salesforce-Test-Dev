/**
 * @description This class is used as wrapper for logging api response in system
 */
@NamespaceAccessible
public with sharing class DataSyncService {

    public Data_Sync_Log__c dataSyncLog;
    public List<Data_Sync_Log__c> dataSyncLogList;
	
    /**
     * @description Constructor that initializes object
     */
    @NamespaceAccessible
    public DataSyncService(){
        dataSyncLog = new Data_Sync_Log__c();
    }
	
    /**
     * @description it inserts Data_Sync_Log__c records
     * @param apiRequest
     * @param eventType
     * @param syncDirection
     */
    @NamespaceAccessible
    public void initialize(String apiRequest, String eventType, String syncDirection){    
        
        dataSyncLog.API_Request__c = apiRequest;
        dataSyncLog.Event_Type__c = eventType;
        dataSyncLog.Sync_Direction__c = syncDirection;
        dataSyncLog.Status__c = System.Label.Data_Sync_Inprogress_Status;

        Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Data_Sync_Log__c;
        Boolean thisUserMayUpdate = drSObj.isCreateable();
        SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                    AccessType.CREATABLE, new List<Data_Sync_Log__c>{dataSyncLog});

        if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
            dataSyncLogList = (List<Data_Sync_Log__c>) securityDecision.getRecords();
            insert dataSyncLogList;

            dataSyncLog.Id = dataSyncLogList[0].Id;
        }
    }
	 
    /**
     * @description it updates status as success with api response
     * @param apiResponse
     */
    @NamespaceAccessible
    public void success(String apiResponse){    
        
        dataSyncLog.Status__c = System.Label.Data_Sync_Success_Status;
        dataSyncLog.API_Response__c = apiResponse;

        Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Data_Sync_Log__c;
        Boolean thisUserMayUpdate = drSObj.isUpdateable();
        SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                    AccessType.UPDATABLE, new List<Data_Sync_Log__c>{dataSyncLog});

        if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
            update securityDecision.getRecords();
        }
    }
	
     /**
     * @description it updates status as error with api response
     * @param apiResponse
     */
    @NamespaceAccessible
    public void error(String apiResponse){    
        
        dataSyncLog.Status__c = System.Label.Data_Sync_Failed_Status;
        dataSyncLog.API_Response__c = apiResponse;

       /* Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Booking__c;
        Boolean thisUserMayUpdate = drSObj.isUpdateable();
        SObjectAccessDecision securityDecision = Security.stripInaccessible(
                                                    AccessType.UPDATABLE, new List<Data_Sync_Log__c>{dataSyncLog});

        if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate){
            update securityDecision.getRecords();
        }*/
    }
}