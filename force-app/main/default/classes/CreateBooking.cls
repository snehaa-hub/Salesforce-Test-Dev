/**
* @description This class is used to create related data required for booking at the time of booking creation
*/
public without sharing class CreateBooking {
    
    /**
    * @description This is an invocable method used to create related data required for booking at the time of booking creation
    * @param requestLst
    */
    @InvocableMethod(label='Create Booking' description='Create Booking Related Records')
    public static void execute(List<Request> requestLst) {
        List<Booking_Line_Item__c> bookingLineItemList = new List<Booking_Line_Item__c>();
        Set<Id> shortListIds = new Set<Id>();
        
        for(Request req: requestLst) {
            if(!String.isBlank(req.bookingId)) {
             /*   if(!String.isBlank(req.bookingLineItem)) {
                    List<Booking_Line_Item__c> bookingLineItems = (List<Booking_Line_Item__c>) JSON.deserialize(
                        req.bookingLineItem,
                        List<Booking_Line_Item__c>.class
                    );
                    
                    if(!bookingLineItems.isEmpty()) {
                        for (Booking_Line_Item__c bookingLineItem : bookingLineItems) {
                            bookingLineItem.Booking__c = req.bookingId;
                            bookingLineItemList.add(bookingLineItem);
                        }
                    }
                }*/
                
                if(!String.isBlank(req.shorListUnits)) {
                    for(String shorListUnit: (List<String>) JSON.deserialize(req.shorListUnits, List<String>.class)) {
                        shortListIds.add(shorListUnit);
                    }
                }
            }
        }
        
        
        if(!shortListIds.isEmpty()) {
            List<Shortlisted_Unit__c> shorListedUnitList = new List<Shortlisted_Unit__c>();
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE,
                                                                        [SELECT Id, Name, Unit__c, Unit__r.Project__c, Status__c,
                                                                         Unit__r.Point_of_Contact__c,
                                                                         Unit__r.Name
                                                                         FROM Shortlisted_Unit__c
                                                                         WHERE Id In: shortListIds]);
            
             
            
            if(!(decision.getRecords()).isEmpty()) {
                for(Shortlisted_Unit__c shorListedUnit: (List<Shortlisted_Unit__c>) decision.getRecords()) {
                    shorListedUnit.Status__c = System.Label.Unit_Status_In_Progress;
                    shorListedUnitList.add(shorListedUnit);
                    
                    Booking_Line_Item__c bookingLineItem = New Booking_Line_Item__c();
                    bookingLineItem.Unit__c = shorListedUnit.Unit__c;
                    bookingLineItem.Booking__c = requestLst[0].bookingId;
                    bookingLineItem.Name = shorListedUnit.Unit__r.Name;
                    bookingLineItem.Landlord__c = shorListedUnit.Unit__r.Point_of_Contact__c;
                    bookingLineItemList.add(bookingLineItem);
                }
            }
            
            if(!bookingLineItemList.isEmpty()) {
            Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Booking_Line_Item__c;
            Boolean thisUserMayUpdate = drSObj.isCreateable();
            SObjectAccessDecision securityDecision = Security.stripInaccessible(
                AccessType.CREATABLE, bookingLineItemList);
            
            if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate) {
                insert securityDecision.getRecords();
            }
        }
        
            if(!shorListedUnitList.isEmpty()) {
                Schema.DescribeSObjectResult drSObj = Schema.sObjectType.Shortlisted_Unit__c;
                Boolean thisUserMayUpdate = drSObj.isUpdateable();
                SObjectAccessDecision securityDecision = Security.stripInaccessible(
                    AccessType.UPDATABLE,  shorListedUnitList);
                
                if(!(securityDecision.getRecords()).isEmpty() && thisUserMayUpdate) {
                    update securityDecision.getRecords();
                }
            }
        }
    }
    
    /**
    * @description This is request wrapper
    */
    public class Request {
        
        @InvocableVariable(label = 'bookingId' description = 'Id of Booking' required = true)
        public String bookingId;
        
        @InvocableVariable(label = 'ShorList Units' description = 'ShorList Units JSON' required = true)
        public String shorListUnits;
        
    }
}