/**
 * @description This class is used in ShowRelatedUnitBundle LWC Component
 */
public without sharing class ShowRelatedUnitBundle {

    /**
     * @description This method is used to fetch all the units that exists in unit bumdle
     * @param linkedUnits
     * @return data in json format
     */
    @Auraenabled()
    public static String fetchUnits(String linkedUnits){
        List<Object> shortUnitIds = (List<Object>) JSON.deserializeuntyped(linkedUnits);
        List<String> shortUnitIdsList = new list<String>();
        
        for(Object shortUnitId: shortUnitIds){
            shortUnitIdsList.add((String) shortUnitId);
        }
        
        List<Map<String,String>> unitMapList = new List<Map<String,String>>();
        if(!shortUnitIdsList.isEmpty()){
            SObjectAccessDecision decision = Security.stripInaccessible(
                                            AccessType.READABLE,
                                            [SELECT 
                                                Id,
                                                Unit__r.Id,
                                                Unit__r.Name,
                                                Unit__r.Unit_Status__c,
                                                Unit__r.Type_of_Unit__c
                                                FROM Shortlisted_Unit__c 
                                                WHERE Id In: shortUnitIdsList
                                                ORDER BY Unit__r.Unit_Category__c, Unit__r.Name ASC
                                            ]);

            if(!(decision.getRecords()).isEmpty()) {
                for(Shortlisted_Unit__c shortUnit: (List<Shortlisted_Unit__c>) decision.getRecords()){
                    Map<String,String> unitMap = new Map<String,String>();
                    unitMap.put('Id',shortUnit.Unit__r.Id);
                    unitMap.put('Name',shortUnit.Unit__r.Name);
                    unitMap.put('Type',shortUnit.Unit__r.Type_of_Unit__c);
                    unitMap.put('Status',shortUnit.Unit__r.Unit_Status__c);
                    unitMapList.add(unitMap);
                }
            }
        }
        
        return JSON.serialize(unitMapList);        
    }
    
    /**
     * @description This method is used to check status of unts in unit bundle
     * @param oppId
     * @return data in json format
     */
    @Auraenabled(cacheable=true)
    public static String checkUnitBundleStatus(String oppId){
        List<Map<String,Object>> objMapList = new List<Map<String,Object>>();

        String unitBundleQuery = 'SELECT Id, Name ';        
        /*unitBundleQuery = unitBundleQuery + '(SELECT Id, Offer__c, Offer__r.Start_Date__c, Offer__r.End_Date__c FROM Applied_Offers__r), ';
        unitBundleQuery = unitBundleQuery + '(SELECT Id, Discount__c, Discount__r.Start_Date__c, Discount__r.End_Date__c FROM Applied_Discounts__r)';*/

        unitBundleQuery = unitBundleQuery + ' FROM Unit_Bundle__c';
        
        if(!String.isBlank(oppId)){
            unitBundleQuery = unitBundleQuery + ' WHERE Opportunity__c = \''+ String.escapeSingleQuotes(oppId) +'\'';
        }
        List<Unit_Bundle__c> unitBundleList = database.query(unitBundleQuery);

        for(Unit_Bundle__c unitBundle: unitBundleList){
            Map<String,Object> objMap = new Map<String,Object>();
            objMap.put('Id',unitBundle.Id);
            Boolean isValid = true;
            Date todayDate = system.today();
            String error;
           /* if(!(unitBundle.Applied_Offers__r).isEmpty()){
                for(Applied_Offer__c appliedOffer: unitBundle.Applied_Offers__r){
                    if(isValid){
                        if(appliedOffer.Offer__r.Start_Date__c <= todayDate && (appliedOffer.Offer__r.End_Date__c == null || todayDate <= appliedOffer.Offer__r.End_Date__c)){
                            
                        }else{
                            isValid = false;
                            error = System.Label.Error_Message_One_of_the_offer_applied_is_out_expired;
                        }
                    }
                }
            }
            
            if(!(unitBundle.Applied_Discounts__r).isEmpty()){
                for(Applied_Discount__c appliedDiscount: unitBundle.Applied_Discounts__r){
                    if(isValid){
                        if(appliedDiscount.Discount__r.Start_Date__c <= todayDate && (appliedDiscount.Discount__r.End_Date__c == null || todayDate <= appliedDiscount.Discount__r.End_Date__c)){
                            
                        }else{
                            isValid = false;
                            error = System.Label.Error_Message_One_of_the_discount_applied_is_out_expired;
                        }
                    }
                }
            }*/
            objMap.put('isValid',isValid);
            objMap.put('errorMessage',error);
            objMapList.add(objMap);
        }
        
        return JSON.serialize(objMapList);
    }
    
    /**
     * @description This method is used to get button name that is enabled for unit bundle
     * @return data in json format
     */
    @Auraenabled(cacheable=true)
    public static String getButtonVisibilityStatus(){
        List<Map<String,Object>> buttonMapList = new List<Map<String,Object>>();
        Map<String, Unit_Bundle_Button_Mapping__mdt> unitBundleButtonMappingMap = Unit_Bundle_Button_Mapping__mdt.getAll();
        
        if(!unitBundleButtonMappingMap.isEmpty()){
            for (String unitBundleButtonMapping : unitBundleButtonMappingMap.keySet()) {
                if(unitBundleButtonMappingMap.get(unitBundleButtonMapping).Is_Enabled__c == true){
                    String labelName = unitBundleButtonMappingMap.get(unitBundleButtonMapping).Button_Label_Name__c;
                    
                    Map<String,Object> buttonMap = new Map<String,Object>();
                    buttonMap.put('Button_Name', System.Label.get('',labelName));
                    
                    buttonMapList.add(buttonMap); 
                }
            }
        }
        
        return JSON.serialize(buttonMapList);
    }    
     @Auraenabled
     Public static String deleteRecord(String recId){
        
        Delete [Select Id from Unit_Bundle__c where Id =:recId];
        return 'Record deleted successfully';
     }
    // @Auraenabled
    //  Public static String deleteRecord(String recId, String oppId, String unitId){
    //     System.debug('141 oppId' +oppId);
    //     System.debug('142 unitId' +unitId);
    //     System.debug('143 recId' +recId);
    //     List<Shortlisted_Unit__c> shortList = [SELECT Id, Opportunity__c, Unit__c 
    //                                            FROM Shortlisted_Unit__c 
    //                                            WHERE Opportunity__c =: oppId AND Unit__c =: unitId];
    //     List<Unit_Bundle__c> unitOption = [Select Id from Unit_Bundle__c where Id =:recId];
    //     System.debug('145 shortList' +shortList);
    //     System.debug('146 unitOption' +unitOption);
	// List<SObject> objList=new List<SObject>();
	// objList.addAll(shortList);
	// objList.addAll(unitOption);
    // System.debug('150 objList: ' +objList);
    // try{
    //     Delete objList;
    // } catch(Exception ex){
    //     System.debug('153 DML Exception: ' +ex.getMessage());
    // }
	
    //     return 'Record deleted successfully';
    //  }

    // ── New method: returns current user's access context ──────────────────────
@AuraEnabled(cacheable=true)
public static String getCurrentUserInfo() {
    User u = [
        SELECT Id, Name, Username, Profile.Name
        FROM User
        WHERE Id = :UserInfo.getUserId()
        LIMIT 1
    ];

    String privilegedUsername = System.Label.Privileged_Non_Admin_User;

    Map<String, Object> info = new Map<String, Object>{
        'isSystemAdmin' => u.Profile.Name == 'System Administrator',
        'isPooja'       => u.Username == privilegedUsername,
        'userName'      => u.Name,
        'userId'        => u.Id
    };
    return JSON.serialize(info);
}

// ── New method: notify all System Admins after Pooja deletes ───────────────
@AuraEnabled
public static void notifyAdminsOfDeletion(String deletedRecordName , String opportunityId) {
    // 1. Collect all active System Admin user IDs
     // Fetch Opportunity name
    String oppName = '';
    if (String.isNotBlank(opportunityId)) {
         Opportunity__c opp = [
            SELECT Name FROM  Opportunity__c WHERE Id = :opportunityId LIMIT 1
        ];
        oppName = opp.Name;
    }
    List<User> admins = [
        SELECT Id FROM User
        WHERE Profile.Name = 'System Administrator'
        AND IsActive = true
    ];
    if (admins.isEmpty()) return;

    // 2. Look up (or create) a Custom Notification Type named 'Unit_Bundle_Alert'
    //    Create it in Setup → Custom Notifications if it doesn't exist yet
    
    List<CustomNotificationType> notifTypes = [
    SELECT Id FROM CustomNotificationType
    WHERE DeveloperName = 'Unit_Bundle_Alert'
    LIMIT 1
];
if (notifTypes.isEmpty()) return; // ← prevents test failure if type not deployed yet
CustomNotificationType notifType = notifTypes[0];

    Set<String> adminIds = new Set<String>();
    for (User u : admins) adminIds.add(u.Id);

    Messaging.CustomNotification notif = new Messaging.CustomNotification();
    notif.setTitle('Unit Bundle Deleted by Pooja');
    notif.setBody('Pooja deleted unit bundle: ' + deletedRecordName + ' | Opportunity: ' + oppName);
    notif.setNotificationTypeId(notifType.Id);
    notif.setTargetId(opportunityId); // links to org home; swap for a specific record Id if preferred
    notif.send(adminIds);
}
}