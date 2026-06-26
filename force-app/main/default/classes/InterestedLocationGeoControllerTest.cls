@isTest
public class InterestedLocationGeoControllerTest  {
@isTest
    static void testGetGeoUpdateMethod() {
        // Insert dummy Interested_Locations__c with null lat/long
        Interested_Locations__c location = new Interested_Locations__c(
            Address__City__s ='Chennai',
            Address__CountryCode__s ='IN',
            Address__PostalCode__s ='600048',
            Address__StateCode__s ='TN',
            Address__Street__s ='Urappakam',
            Interested_Location_Range__c = 25
          
        );
        insert location;


        Test.startTest();
        // Call method which internally triggers future method
        InterestedLocationGeoController.getGeoupdateMethod(new List<Interested_Locations__c>{location});
        Test.stopTest();

        // Reload record to verify if lat/long were updated
        Interested_Locations__c updated = [SELECT Address__Latitude__s, Address__Longitude__s FROM Interested_Locations__c WHERE Id = :location.Id];
        System.assertNotEquals(null, updated.Address__Latitude__s, 'Latitude should be updated');
        System.assertNotEquals(null, updated.Address__Longitude__s, 'Longitude should be updated');
    }
}