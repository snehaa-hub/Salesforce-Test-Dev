@isTest
private class QuotePdfController_Test {

    @isTest
    static void testConstructorWithValidJson() {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        User u = new User();
        u.FirstName = 'test';
        u.LastName = 'test';
        u.Alias = 'ttest';
        u.Email = 'test@gmail.com';
        u.Username = 'test@gmail.com.stylam202204';
        u.CommunityNickname = 'test';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = pf.Id;
        INSERT u;
        PermissionSet newPermission = [SELECT Id FROM PermissionSet WHERE Name = 'Object_Permission'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = newPermission.Id;
        INSERT psa;
        system.runAs(u){
            List<QuotePdfController.UnitBundle> unitBundles = new List<QuotePdfController.UnitBundle>();
            Opportunity__c opp = new Opportunity__c(
                Name = 'Test Opportunity',
                Stage__c = 'In Progress',
                Close_Date__c = Date.today().addDays(30),
                Proposal_Json__c = '[{"selectedUnitBundleId":"a0DF6000008TlgsMAC","selectedUnitBundleName":"Bundle - 2","shortListUnits":[{"shortListId":{"Id":"a0GF6000008QNhgMAG","Name":"a0GF6000008QNhg","Type_of_Unit__c":"Factory","Unit_Category__c":"Individual","Built_up_Area__c":125000,"Saleable_Area__c":125000,"Year_of_Construction__c":"below 5 years","Lighting__c":"Both","Dock_Leveller_Text__c":"Can be discussed","Floor_Type__c":"VDF","Canopy_available__c":"Yes","Power_availabletext__c":"112 Kw","Floor_Insulation__c":"Yes","Ventilation__c":"Ridge vent","No_of_toilets__c":"5","Authority__c":"DTCP","Approval_plan_available__c":"Yes","Maintenance_by__c":"Tenant","Maintenance__c":"3","EoT_Crane_Provision_Text__c":"10 Ton","Date_Available__c":"2024-09-26","No_of_shutters__c":"5","City__c":"Hyderabad","Ceiling_Center_Height__c":35,"Ceiling_Center_Height_UOM__c":"Feet","Ceiling_Side_Height__c":30,"Ceiling_Side_Height_UOM__c":"Feet","Fire_Noc_available__c":"Yes","Flooring_Strength_per_MT__c":"6.5","Fire_Safety__c":"Hydrants","Canopy__c":"Only fir docks","Power_available__c":"Yes","Google_Coordinates_Link__c":"https://www.google.com/maps/place/Hyderabad,+Telangana/@17.4127332,78.0783691,92232m/data=!3m2!1e3!4b1!4m6!3m5!1s0x3bcb99daeaebd2c7:0xae93b78392bafbc2!8m2!3d17.406498!4d78.4772439!16zL20vMDljNnc?entry=ttu&g_ep=EgoyMDI0MDkwNC4wIKXMDSoASAFQAw%3D%3D","Dock_Leveller__c":"No","Office_space_available__c":"Yes","EoT_Crane_Provision__c":"Yes","Rent_per_uom_Price_per_uom__c":25,"Building_Type__c":"PEB","Floor_ht_from_ground_level__c":"4","Floor_ht_from_ground_level_UOM__c":"Feet","SIDCO_SIPCOT_CAM_or_Addl_Charges__c":6878,"SIDCO_SIPCOT_CAM_Addl_Charges_UOM__c":"Sq. Feet","Total_Rent_Total_Price_Text__c":3125000,"Built_Up_Area_UOM__c":"Sq. Feet","Saleable_Area_UOM__c":"Sq. Feet"},"selectedContentVersionID":["/sfc/servlet.shepherd/version/download/068F6000002WTfZIAW"]}]}]'
            );
            insert opp;
           /* QuotePdfController.UnitBundle unitBundle = new QuotePdfController.UnitBundle();
            unitBundle.selectedUnitBundleId = 'bundle1';
            unitBundle.selectedUnitBundleName = 'Sample Bundle';
            unitBundle.shortListUnits = new List<QuotePdfController.ShortListUnit>();
            
            QuotePdfController.ShortListUnit shortListUnit = new QuotePdfController.ShortListUnit();
            shortListUnit.shortListId = new Unit__c();
            shortListUnit.selectedContentVersionID = new List<String>{ 'contentVersionId1', 'contentVersionId2' };
            unitBundle.shortListUnits.add(shortListUnit);
            
            unitBundles.add(unitBundle);
            
            String jsonData = JSON.serialize(unitBundles);*/
            
            Test.setCurrentPageReference(new PageReference('Page.MyPage')); 
            ApexPages.currentPage().getParameters().put('id', opp.ID);
            
            Test.startTest();
            QuotePdfController controller = new QuotePdfController();
            Test.stopTest();
        
        }
    }
}