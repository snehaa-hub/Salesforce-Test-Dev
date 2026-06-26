global class SendRemindersBatch implements Database.Batchable<SObject>, Schedulable {
    public integer firstReminderDate;
    public integer secondReminderDate;
    public integer thirdReminderDate;
    public integer fourthReminderDate;
    public List<Invoice_Reminder__mdt> invoiceReminder ;
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
         invoiceReminder = [
            SELECT Id, First_Reminder__c, Fourth_Reminder__c, 
                   Third_Reminder__c, Second_Reminder__c 
            FROM Invoice_Reminder__mdt LIMIT 1
        ];

        if (!invoiceReminder.isEmpty()) {
            firstReminderDate = Integer.valueOf(invoiceReminder[0].First_Reminder__c);
            secondReminderDate = Integer.valueOf(invoiceReminder[0].Second_Reminder__c);
            thirdReminderDate = Integer.valueOf(invoiceReminder[0].Third_Reminder__c);
            fourthReminderDate = Integer.valueOf(invoiceReminder[0].Fourth_Reminder__c);
        }
        
 
         String query = 'SELECT Id, ' + 
                       'Name, ' +
           				'Landlord_name__r.PersonEmail ,' +
                       'Next_Reminder_Date__c, ' +
                       'Reminder_Week__c, ' +
           				'Booking_Invoice_Date__c ,' +
                       'CreatedDate, ' +
           				' Owner.Email,'+
                        ' Tenant__c, '+
                       ' Landlord_name__c '+
                      ' FROM Booking__c ' +
             		      'WHERE reminder__c = false ' +
               'AND Landlord_name__r.PersonEmail != null '+
             	'AND Owner.Email != null';
        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext BC, List<Booking__c> scope) {
        system.debug('scope'+scope);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> emailTemp = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'Transaction_Assignment'];
        List<Booking__c> updateBooking = new List<Booking__c>();

           if (!scope.isEmpty()) {
            for (Booking__c booking : scope) {
                system.debug('scope'+scope);
             if (booking.Tenant__c != null  && booking.Landlord_name__c != null) {
                   Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemp[0].Id, null, booking.Id);
                        mail.setToAddresses(new List<String>{booking.Landlord_name__r.PersonEmail});
                        mail.setCcAddresses(new List<String>{booking.Owner.Email});
                        mail.setSaveAsActivity(false);
                        mails.add(mail);
                	 Date nextReminderDate;
                 if (booking.Reminder_Week__c == 'First Week') {
                     if (booking.Next_Reminder_Date__c == null) {
                        system.debug('First'+firstReminderDate);
                     	 nextReminderDate = booking.Booking_Invoice_Date__c.addDays(firstReminderDate);
                     }}	
                    else if (booking.Reminder_Week__c == 'Second Week') {
                       if (booking.Next_Reminder_Date__c != null) {
                            nextReminderDate = booking.Next_Reminder_Date__c.addDays(secondReminderDate);
                        }
                        system.debug('secondReminderDate'+booking.Next_Reminder_Date__c);
                    } else if (booking.Reminder_Week__c == 'Third Week') {
                        if (booking.Next_Reminder_Date__c != null) {
                       		nextReminderDate =  booking.Next_Reminder_Date__c.addDays(thirdReminderDate);
            			 	system.debug('ThirdReminderDate'+booking.Next_Reminder_Date__c);
                        }} else {
                       if (booking.Next_Reminder_Date__c != null) {
                       nextReminderDate =  booking.Next_Reminder_Date__c.addDays(fourthReminderDate);
            
                         system.debug('fourthReminderDate'+booking.Next_Reminder_Date__c);
                       } }
                     booking.Next_Reminder_Date__c = nextReminderDate;
                    	updateBooking.add(booking);
					 
                }
            }

            if (!mails.isEmpty()) {
             Messaging.sendEmail(mails);
            }

            if (!updateBooking.isEmpty()) {
                update updateBooking;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Any post-batch cleanup or processing can be done here
    }

    global void execute(SchedulableContext sc) {
        SendRemindersBatch batch = new SendRemindersBatch();
        Database.executeBatch(batch);
    }
}