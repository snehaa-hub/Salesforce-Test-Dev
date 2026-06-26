public without sharing class DeletionNotificationService {

    private static final String NOTIF_API_NAME = 'Record_Deletion_Alert';

    @TestVisible private static String monitoredUsername = Label.Monitored_User_Username;
    @TestVisible private static String adminUsername     = Label.Admin_Notification_Username;

    public static void notifyOnDeletion(List<SObject> records, String objectLabel) {

        // 1. Only proceed if running user is Pooja
        if (UserInfo.getUserName() != monitoredUsername) return;

        // 2. Get Aarti's Id and Email
        List<User> adminUsers = [
            SELECT Id, Email
            FROM User
            WHERE Username = :adminUsername
            AND IsActive = true
            LIMIT 1
        ];
        if (adminUsers.isEmpty()) {
            System.debug('Admin user not found: ' + adminUsername);
            return;
        }

        // 3. Build record names list
List<String> names = new List<String>();
for (Integer i = 0; i < Math.min(records.size(), 5); i++) {
    String n = '';
    try { n = (String) records[i].get('Name'); } catch (Exception e) {}
    // ContentDocument uses Title instead of Name
    if (String.isBlank(n)) {
        try { n = (String) records[i].get('Title'); } catch (Exception e) {}
    }
    if (String.isNotBlank(n)) names.add(n);
}
String recordNames = names.isEmpty() ? 'Unknown' : String.join(names, ', ');
if (records.size() > 5) {
    recordNames += '... (+' + (records.size() - 5) + ' more)';
}
        Integer count       = records.size();
        String deletedBy    = UserInfo.getName();
        String deletedAt    = Datetime.now().format('dd/MM/yyyy hh:mm a');
        String title        = 'Deletion Alert — ' + objectLabel;
        String body         = deletedBy + ' deleted ' + count + ' '
                            + objectLabel + ' record' + (count > 1 ? 's' : '')
                            + ': ' + recordNames
                            + ' on ' + deletedAt;

        // 4. Send bell notification
        try {
            List<CustomNotificationType> notifTypes = [
                SELECT Id FROM CustomNotificationType
                WHERE DeveloperName = :NOTIF_API_NAME
                LIMIT 1
            ];
            if (!notifTypes.isEmpty()) {
                Messaging.CustomNotification notif = new Messaging.CustomNotification();
                notif.setTitle(title);
                notif.setBody(body);
                notif.setNotificationTypeId(notifTypes[0].Id);
                notif.setTargetId(adminUsers[0].Id);
                notif.send(new Set<String>{ adminUsers[0].Id });
                System.debug('Bell notification sent');
            }
        } catch (Exception e) {
            System.debug('Bell notification failed: ' + e.getMessage());
        }

        // 5. Send email to Aarti with full details
        try {
            String emailBody = '<html><body style="font-family: Arial, sans-serif;">'
                + '<h2 style="color:#c0392b;">Record Deletion Alert</h2>'
                + '<table style="border-collapse:collapse; width:100%;">'
                + '<tr style="background:#f2f2f2;">'
                +   '<td style="padding:10px; border:1px solid #ddd;"><b>Deleted By</b></td>'
                +   '<td style="padding:10px; border:1px solid #ddd;">' + deletedBy + '</td>'
                + '</tr>'
                + '<tr>'
                +   '<td style="padding:10px; border:1px solid #ddd;"><b>Object</b></td>'
                +   '<td style="padding:10px; border:1px solid #ddd;">' + objectLabel + '</td>'
                + '</tr>'
                + '<tr style="background:#f2f2f2;">'
                +   '<td style="padding:10px; border:1px solid #ddd;"><b>Record(s) Deleted</b></td>'
                +   '<td style="padding:10px; border:1px solid #ddd;">' + recordNames + '</td>'
                + '</tr>'
                + '<tr>'
                +   '<td style="padding:10px; border:1px solid #ddd;"><b>Total Count</b></td>'
                +   '<td style="padding:10px; border:1px solid #ddd;">' + count + '</td>'
                + '</tr>'
                + '<tr style="background:#f2f2f2;">'
                +   '<td style="padding:10px; border:1px solid #ddd;"><b>Deleted At</b></td>'
                +   '<td style="padding:10px; border:1px solid #ddd;">' + deletedAt + '</td>'
                + '</tr>'
                + '</table>'
                + '<p style="color:#888; font-size:12px; margin-top:20px;">'
                + 'This is an automated alert from AllWarehouses Salesforce.</p>'
                + '</body></html>';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ adminUsers[0].Email });
            mail.setSubject('Deletion Alert — ' + objectLabel + ' | ' + deletedAt);
            mail.setHtmlBody(emailBody);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            System.debug('Email sent to Aarti: ' + adminUsers[0].Email);

        } catch (Exception e) {
            System.debug('Email send failed: ' + e.getMessage());
        }
    }
}