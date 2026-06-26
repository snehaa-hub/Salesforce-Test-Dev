/**
* @description This class is used to get all the user's that are currently present at a specific sales gallery(location)
*/
public without sharing class GetUsersPresent {
    
    /**
* @description This invocable method is used to get all the user's that are currently present at a specific sales gallery(location)
* @param requestList
* @return list of response
*/
    @InvocableMethod(label='Get Users Present In Sales Office' description='Get Users Present In Sales Office')
    public static List<Response> execute(List<Request> requestList) {
        List<Response> responseList = new List<Response>();
        if(!requestList.isEmpty()){
            Set<String> permissionNameList = new Set<String>();
            Set<String> salesOfficeList = new Set<String>();
            
            for(Request req: requestList){
                permissionNameList.add(req.permissionName);
                if(!String.isBlank(req.salesOffice)){
                    salesOfficeList.add(req.salesOffice);
                }
            }
            
            Set<String> permissionSetIdList = new Set<String>();
            SObjectAccessDecision decision = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT ParentId FROM SetupEntityAccess WHERE SetupEntityId IN 
                 (SELECT Id FROM CustomPermission WHERE DeveloperName In: permissionNameList)]);
            
            if(!(decision.getRecords()).isEmpty()) {
                for (SetupEntityAccess access : (List<SetupEntityAccess>) decision.getRecords()) {
                    permissionSetIdList.add(access.ParentId);
                }
            }
            
            Set<String> userIds = new Set<String>();
            Set<String> usersPresent = new Set<String>();
            if(!permissionSetIdList.isEmpty()){
                SObjectAccessDecision decisionPermissionSetAssignment = Security.stripInaccessible(
                    AccessType.READABLE,
                    [SELECT 
                     Id,
                     AssigneeId,
                     IsActive,
                     PermissionSetId 
                     FROM PermissionSetAssignment
                     WHERE PermissionSetId In:permissionSetIdList
                    ]);
               
                if(!(decisionPermissionSetAssignment.getRecords()).isEmpty()) {
                    for(PermissionSetAssignment permissionSetAssign: (List<PermissionSetAssignment>) decisionPermissionSetAssignment.getRecords()){
                        userIds.add(permissionSetAssign.AssigneeId);
                    }
                }
            }
            
            
            /* if(!salesOfficeList.isEmpty() && !userIds.isEmpty()){
SObjectAccessDecision decisionAttendance = Security.stripInaccessible(
AccessType.READABLE,
[SELECT 
Id,
User__c
FROM Attendance__c
WHERE 
Location__c In: salesOfficeList 
AND
User__c In: userIds
AND
Date__c =: system.today()
]);

if(!(decisionAttendance.getRecords()).isEmpty()) {

for(Attendance__c attendance: (List<Attendance__c>) decisionAttendance.getRecords()){                       
usersPresent.add(attendance.User__c);
}
}
}*/
            
           List<String> usersPresentList = new List<String>();
            if(!usersPresent.isEmpty()){
                usersPresentList.addAll(usersPresent);
            }else{
                usersPresentList.addAll(userIds);
            }
            
            Response res = new Response();
            res.userIds = usersPresentList;
            responseList.add(res);
        }
        return responseList;
    }
    
    /**
* @description This is request wrapper
*/
    public class Request {
        @InvocableVariable(label='Sales Office' required=false)
        public String salesOffice;
        
        @InvocableVariable(label='Permission Name' required=true)
        public String permissionName;
    }
    
    /**
* @description This is response wrapper
*/
    public class Response {
        @InvocableVariable(label='Id of Users Present' required=true)
        public List<String> userIds;
    }
}