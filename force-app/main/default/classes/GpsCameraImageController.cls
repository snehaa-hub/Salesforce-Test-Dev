/**
* @File Name : GpsCameraImageController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 6, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 6, 2025 |   | Initial Version
**/

public class GpsCameraImageController {
	@AuraEnabled
	public static void saveImage(String imageData,String parentId, String locationurl, String objType,String pickval){
			String base64Prefix = 'data:image/png;base64,';
if (imageData != null && imageData.startsWith(base64Prefix)) {
    String base64Data = imageData.substring(base64Prefix.length());
    Blob imageBlob = EncodingUtil.base64Decode(base64Data);
	Unit__c units = [SELECT Id,Name,Unit_Number__c FROM Unit__c WHERE Id = :parentId];
	List<ContentVersion> fileslist = [SELECT Id,SObjectType__c,Title, FirstPublishLocationId From ContentVersion where SObjectType__c ='Unit__c' AND FirstPublishLocationId =:parentId AND FileType !='PDF'];
	// DateTime gmtNow = System.now();
	// 	TimeZone userTimeZone = UserInfo.getTimeZone();
	// 	DateTime userDateTime = gmtNow.addSeconds(userTimeZone.getOffset(gmtNow) / 1000);
		Integer currentfile = fileslist.Size()+1;
		ContentVersion cv = new ContentVersion();
		cv.Title = 'Image '+currentfile+' ('+units.Name+')';
		cv.PathOnClient = 'Image '+currentfile+'('+units.Name+').png';
		cv.ContentLocation = 'S';
		cv.VersionData = imageBlob;
		cv.Document_Type__c = pickval;
		cv.IsMajorVersion = true;
		cv.SObjectType__c = 'Unit__c';
		cv.FirstPublishLocationId = units.Id;
		try{
		insert cv;
		}catch(DmlException e){
			System.debug('inserted failed  :'+e.getMessage());
		}

	System.debug('inserted  :'+cv);
		// Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

		// ContentDocumentLink cdl = new ContentDocumentLink();
		// cdl.ContentDocumentId = contentDocId;
		// cdl.LinkedEntityId = parentId; // e.g., Account ID
		// cdl.ShareType = 'V'; // Viewer
		// cdl.Visibility = 'AllUsers';
		// insert cdl;

		if(cv != null && locationurl !='' ){
			
			Unit__c unit= new Unit__c();
			unit.Id =parentId;
            if(!Test.isRunningTest()){
                String location = 'https://www.google.com/maps/place/'+locationurl;
                unit.Google_Coordinates_Link__c = location;
			update unit;
            }
			
		}
}

	}
		@AuraEnabled
	public static void saveSiteVisitImage(String imageData,String parentId){
			String base64Prefix = 'data:image/png;base64,';
if (imageData != null && imageData.startsWith(base64Prefix)) {
    String base64Data = imageData.substring(base64Prefix.length());
    Blob imageBlob = EncodingUtil.base64Decode(base64Data);
		Site_Visit__c sv = [SELECT Id, Name,Unit_Bundle__c FROM Site_Visit__c WHERE Id = :parentId];
    	Unit_Bundle__c Ub = [SELECT Linked_Unit__c FROM Unit_Bundle__c Where Id =: sv.Unit_Bundle__c];
		List<ContentVersion> fileslist = [SELECT Id,SObjectType__c,Title, FirstPublishLocationId From ContentVersion where SObjectType__c ='Site_Visit__c' AND FirstPublishLocationId =:sv.Id AND FileType !='PDF'];
    	String fileName ='';
    	if(!String.isBlank(Ub.Linked_Unit__c)){
                List<String> shortListedUnits = (List<String>) JSON.deserialize(Ub.Linked_Unit__c,List<String>.class);
									List<Shortlisted_Unit__c> shortListedUnit = [SELECT Id, Unit__c, Unit__r.Tower_Block__c,
                                                Unit__r.Name, Unit_Status__c,
                                                Unit__r.Tower_Block__r.Name, Unit__r.Floor__c,
                                                Unit__r.Type_of_Unit__c, Unit__r.Unit_Category__c
                                                FROM Shortlisted_Unit__c
                                                WHERE Id In: shortListedUnits
                                            ];
            fileName = shortListedUnit[0].Unit__r.Name;
        }
    	// DateTime gmtNow = System.now();
		// TimeZone userTimeZone = UserInfo.getTimeZone();
		// DateTime userDateTime = gmtNow.addSeconds(userTimeZone.getOffset(gmtNow) / 1000);
		// System.debug('User Time: ' + userDateTime);
		// String currentdate = String.valueOf(userDateTime);
		Integer currentfile = fileslist.Size()+1;
		ContentVersion cv = new ContentVersion();
    	String filesName = fileName !=''?'('+fileName+')':'';
		cv.Title = 'Image '+currentfile +filesName ;
		cv.PathOnClient = 'Image '+currentfile+filesName+'.png';
		cv.ContentLocation = 'S';
		cv.VersionData = imageBlob;
		cv.IsMajorVersion = true;
		cv.SObjectType__c = 'Site_Visit__c';
		cv.FirstPublishLocationId = sv.Id;
		try{
		insert cv;
            saveOpportunityImage(imageData, parentId);
		}catch(DmlException e){
			System.debug('inserted failed  :'+e.getMessage());
		}

	System.debug('inserted  :'+cv);
		// Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

		// ContentDocumentLink cdl = new ContentDocumentLink();
		// cdl.ContentDocumentId = contentDocId;
		// cdl.LinkedEntityId = parentId; // e.g., Account ID
		// cdl.ShareType = 'V'; // Viewer
		// cdl.Visibility = 'AllUsers';
		// insert cdl;
}

	}
    	@AuraEnabled
	public static void saveOpportunityImage(String imageData,String parentId){
			String base64Prefix = 'data:image/png;base64,';
if (imageData != null && imageData.startsWith(base64Prefix)) {
    String base64Data = imageData.substring(base64Prefix.length());
    Blob imageBlob = EncodingUtil.base64Decode(base64Data);
		Site_Visit__c sv = [SELECT Id, Name,Unit_Bundle__c,Opportunity__c  FROM Site_Visit__c WHERE Id = :parentId];
    	Opportunity__c ov = [Select Id, Name from Opportunity__c Where Id =:sv.Opportunity__c ];
    	Unit_Bundle__c Ub = [SELECT Linked_Unit__c FROM Unit_Bundle__c Where Id =: sv.Unit_Bundle__c];
		List<ContentVersion> fileslist = [SELECT Id,SObjectType__c,Title, FirstPublishLocationId From ContentVersion where SObjectType__c ='Opportunity__c' AND FirstPublishLocationId =:ov.Id AND FileType !='PDF'];
    	String fileName ='';
    	if(!String.isBlank(Ub.Linked_Unit__c)){
                List<String> shortListedUnits = (List<String>) JSON.deserialize(Ub.Linked_Unit__c,List<String>.class);
									List<Shortlisted_Unit__c> shortListedUnit = [SELECT Id, Unit__c, Unit__r.Tower_Block__c,
                                                Unit__r.Name, Unit_Status__c,
                                                Unit__r.Tower_Block__r.Name, Unit__r.Floor__c,
                                                Unit__r.Type_of_Unit__c, Unit__r.Unit_Category__c
                                                FROM Shortlisted_Unit__c
                                                WHERE Id In: shortListedUnits
                                            ];
            fileName = shortListedUnit[0].Unit__r.Name;
        }
    String contentDocumentType = 'Site Visit Image';
    	// DateTime gmtNow = System.now();
		// TimeZone userTimeZone = UserInfo.getTimeZone();
		// DateTime userDateTime = gmtNow.addSeconds(userTimeZone.getOffset(gmtNow) / 1000);
		// System.debug('User Time: ' + userDateTime);
		// String currentdate = String.valueOf(userDateTime);
		Integer currentfile = fileslist.Size()+1;
		ContentVersion cv = new ContentVersion();
    	String filesName = fileName !=''?'('+fileName+')':'';
		cv.Title = 'Image '+currentfile +filesName ;
		cv.PathOnClient = 'Image '+currentfile+filesName+'.png';
		cv.ContentLocation = 'S';
		cv.VersionData = imageBlob;
		cv.IsMajorVersion = true;
		cv.SObjectType__c = 'Opportunity__c';
        cv.Document_Type__c = contentDocumentType;
		cv.FirstPublishLocationId = ov.Id;
		try{
		insert cv;
		}catch(DmlException e){
			System.debug('inserted failed  :'+e.getMessage());
		}

	System.debug('inserted  :'+cv);
		// Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

		// ContentDocumentLink cdl = new ContentDocumentLink();
		// cdl.ContentDocumentId = contentDocId;
		// cdl.LinkedEntityId = parentId; // e.g., Account ID
		// cdl.ShareType = 'V'; // Viewer
		// cdl.Visibility = 'AllUsers';
		// insert cdl;
}

	}
}