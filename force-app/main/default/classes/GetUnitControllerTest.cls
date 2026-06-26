@isTest
public class GetUnitControllerTest {
    
    @testSetup
    static void setup() {
        List<Unit__c> units = new List<Unit__c>();
        
        Unit__c unitData = new Unit__c();
        unitData.Type_of_Unit__c = 'Shed';
        unitData.City__c = 'City1';
        unitData.Country__c = 'Country1';
        unitData.Postal_Code__c = '12345';
        unitData.Chargeable_Area__c = 1500;
        unitData.Saleable_Area__c = 1500;
        unitData.State__c = 'State1';
        unitData.Street__c = 'Street1';
        unitData.Unit_Status__c = 'Available';
        unitData.Unit_Location__Latitude__s = 30.7333;
        unitData.Unit_Location__Longitude__s = 76.7794;
        unitData.Budget__c = '2.5 lakh to 5 lakh';
        unitData.Size_Range__c = '10000 - 25000';
        unitData.Unit_Category__c = 'SIPCOT';
        unitData.EoT_Crane_Provision__c = 'Yes';
        unitData.Date_Available__c = Date.newInstance(2025, 4, 22);
        
        units.add(unitData);
        
        if(!units.isEmpty()){
            insert units;  
        }
    }

    @isTest
    static void testGetFilteredUnits2() {
        
        Unit__c unit = [
            SELECT Id, Type_of_Unit__c, City__c, Country__c,
                   Unit_Category__c, EoT_Crane_Provision__c,
                   Postal_Code__c, Chargeable_Area__c,
                   State__c, Unit_Status__c,
                   Unit_Location__Latitude__s,
                   Unit_Location__Longitude__s,
                   Budget__c, Name
            FROM Unit__c
            LIMIT 1
        ];
        
        unit.Budget__c = '2.5 lakh to 5 lakh';
        unit.Type_of_Unit__c = 'Shed';
        unit.Chargeable_Area__c = 0;
        unit.Unit_Category__c = 'SIPCOT';
        unit.EoT_Crane_Provision__c ='Yes';
        
        update unit;
        
        Test.startTest();
        
        String selectedBudgetType = unit.Budget__c;
        String typeOfUnit = unit.Type_of_Unit__c;
        String unitCategory = unit.Unit_Category__c;
        String eotCrane = unit.EoT_Crane_Provision__c;
        
        double maxArea = unit.Chargeable_Area__c;
        double minArea = unit.Chargeable_Area__c;
        
        Decimal radius = 10;
        Decimal longitude = 76.7794;
        Decimal latitude = 30.7333;
        
        List<Object> interestedLocations = new List<Object>{
            new Map<String, Object>{
                'location' => new Map<String, Object>{
                    'Latitude' => 30.0,
                    'Longitude' => 76.0
                }
            },
            new Map<String, Object>{
                'location' => new Map<String, Object>{
                    'Latitude' => 31.0,
                    'Longitude' => 77.0
                }
            }
        };
        
        GetUnitController.getInterestedLocationsUnit(
            selectedBudgetType,
            typeOfUnit,
            unitCategory,
            eotCrane,
            maxArea,
            minArea,
            latitude,
            longitude,
            radius,
            interestedLocations
        );

        Test.stopTest();
    }

    @isTest
    static void testGetFilteredUnits3() {
        
        Unit__c unit = [
            SELECT Id, Type_of_Unit__c, City__c, Country__c,
                   Postal_Code__c, Chargeable_Area__c,
                   State__c, Unit_Status__c,
                   Unit_Location__Latitude__s,
                   Unit_Location__Longitude__s,
                   Budget__c, Name,
                   Unit_Category__c,
                   EoT_Crane_Provision__c
            FROM Unit__c
            LIMIT 1
        ];
        
        unit.Budget__c = null;
        unit.Type_of_Unit__c = null;
        unit.Chargeable_Area__c = 0;
        unit.Unit_Category__c = 'SIPCOT';
        unit.EoT_Crane_Provision__c ='Yes';
        
        update unit;
        
        Test.startTest();
        
        String selectedBudgetType = unit.Budget__c;
        String typeOfUnit = unit.Type_of_Unit__c;
        String unitCategory = unit.Unit_Category__c;
        String eotCrane = unit.EoT_Crane_Provision__c;
        
        double maxArea = unit.Chargeable_Area__c;
        double minArea = unit.Chargeable_Area__c;
        
        Decimal radius = 10;
        Decimal longitude = 76.7794;
        Decimal latitude = 30.7333;
        
        List<Object> interestedLocations = new List<Object>{
            new Map<String, Object>{
                'location' => new Map<String, Object>{
                    'Latitude' => 30.0,
                    'Longitude' => 76.0
                }
            },
            new Map<String, Object>{
                'location' => new Map<String, Object>{
                    'Latitude' => 31.0,
                    'Longitude' => 77.0
                }
            }
        };
        
        GetUnitController.getInterestedLocationsUnit(
            selectedBudgetType,
            typeOfUnit,
            unitCategory,
            eotCrane,
            maxArea,
            minArea,
            latitude,
            longitude,
            radius,
            interestedLocations
        );

        Test.stopTest();
    }

    @isTest
    static void testGetFilteredUnits4() {
        
        Unit__c unit = [
            SELECT Id, Type_of_Unit__c, City__c, Country__c,
                   Postal_Code__c, Chargeable_Area__c,
                   State__c, Unit_Status__c,
                   Unit_Location__Latitude__s,
                   Unit_Location__Longitude__s,
                   Budget__c, Name,
                   Unit_Category__c,
                   EoT_Crane_Provision__c
            FROM Unit__c
            LIMIT 1
        ];
        
        unit.Budget__c = '';
        unit.Type_of_Unit__c = '';
        unit.Chargeable_Area__c = 0;
        unit.Unit_Category__c = 'SIPCOT';
        unit.EoT_Crane_Provision__c ='Yes';
        
        update unit;
        
        Test.startTest();
        
        String selectedBudgetType = unit.Budget__c;
        String typeOfUnit = unit.Type_of_Unit__c;
        String unitCategory = unit.Unit_Category__c;
        String eotCrane = unit.EoT_Crane_Provision__c;
        
        double maxArea = unit.Chargeable_Area__c;
        double minArea = unit.Chargeable_Area__c;
        
        Decimal radius = 10;
        Decimal longitude = 76.7794;
        Decimal latitude = 30.7333;
        
        List<Object> interestedLocations = new List<Object>{
            new Map<String, Object>{
                'location' => new Map<String, Object>{
                    'Latitude' => 30.0,
                    'Longitude' => 76.0
                }
            },
            new Map<String, Object>{
                'location' => new Map<String, Object>{
                    'Latitude' => 31.0,
                    'Longitude' => 77.0
                }
            }
        };
        
        GetUnitController.getInterestedLocationsUnit(
            selectedBudgetType,
            typeOfUnit,
            unitCategory,
            eotCrane,
            maxArea,
            minArea,
            latitude,
            longitude,
            radius,
            interestedLocations
        );

        Test.stopTest();
    }

    @isTest
    static void testGetFilteredUnits5() {
        
        Unit__c unit = [
            SELECT Id, Type_of_Unit__c, City__c, Country__c,
                   Postal_Code__c, Chargeable_Area__c,
                   State__c, Unit_Status__c,
                   Unit_Location__Latitude__s,
                   Unit_Location__Longitude__s,
                   Budget__c, Name,
                   Unit_Category__c,
                   EoT_Crane_Provision__c
            FROM Unit__c
            LIMIT 1
        ];
        
        unit.Budget__c = '';
        unit.Type_of_Unit__c = 'Shed';
        unit.Chargeable_Area__c = 0;
        unit.Unit_Category__c = 'SIPCOT';
        unit.EoT_Crane_Provision__c ='Yes';
        
        update unit;
        
        Test.startTest();
        
        String selectedBudgetType = unit.Budget__c;
        String typeOfUnit = unit.Type_of_Unit__c;
        String unitCategory = unit.Unit_Category__c;
        String eotCrane = unit.EoT_Crane_Provision__c;
        
        double maxArea = unit.Chargeable_Area__c;
        double minArea = unit.Chargeable_Area__c;
        
        Decimal radius = 10;
        Decimal longitude = 76.7794;
        Decimal latitude = 30.7333;
        
        List<Object> interestedLocations = new List<Object>{
            new Map<String, Object>{
                'location' => new Map<String, Object>{
                    'Latitude' => 30.0,
                    'Longitude' => 76.0
                }
            },
            new Map<String, Object>{
                'location' => new Map<String, Object>{
                    'Latitude' => 31.0,
                    'Longitude' => 77.0
                }
            }
        };
        
        GetUnitController.getInterestedLocationsUnit(
            selectedBudgetType,
            typeOfUnit,
            unitCategory,
            eotCrane,
            maxArea,
            minArea,
            latitude,
            longitude,
            radius,
            interestedLocations
        );

        Test.stopTest();
    }

    @isTest
    static void testGetFilteredUnits6() {
        
        Unit__c unit = [
            SELECT Id, Type_of_Unit__c, City__c, Country__c,
                   Postal_Code__c, Chargeable_Area__c,
                   State__c, Unit_Status__c,
                   Unit_Location__Latitude__s,
                   Unit_Location__Longitude__s,
                   Budget__c, Name,
                   Unit_Category__c,
                   EoT_Crane_Provision__c
            FROM Unit__c
            LIMIT 1
        ];
        
        unit.Budget__c = '2.5 lakh to 5 lakh';
        unit.Type_of_Unit__c = 'Shed';
        unit.Chargeable_Area__c = 100;
        unit.Unit_Category__c = 'SIPCOT';
        unit.EoT_Crane_Provision__c ='Yes';
        
        update unit;
        
        Test.startTest();
        
        String selectedBudgetType = unit.Budget__c;
        String typeOfUnit = unit.Type_of_Unit__c;
        String unitCategory = unit.Unit_Category__c;
        String eotCrane = unit.EoT_Crane_Provision__c;
        
        double maxArea = unit.Chargeable_Area__c;
        double minArea = unit.Chargeable_Area__c;
        
        Decimal radius = 10;
        Decimal longitude = 76.7794;
        Decimal latitude = 30.7333;
        
        List<Object> interestedLocations = new List<Object>{
            new Map<String, Object>{
                'location' => new Map<String, Object>{
                    'Latitude' => 30.0,
                    'Longitude' => 76.0
                }
            },
            new Map<String, Object>{
                'location' => new Map<String, Object>{
                    'Latitude' => 31.0,
                    'Longitude' => 77.0
                }
            }
        };
        
        GetUnitController.getInterestedLocationsUnit(
            selectedBudgetType,
            typeOfUnit,
            unitCategory,
            eotCrane,
            maxArea,
            minArea,
            latitude,
            longitude,
            radius,
            interestedLocations
        );

        Test.stopTest();
    }

    @isTest
    static void getDataByUnitNumber() {
        
        List<Unit__c> units = new List<Unit__c>();
        
        Unit__c unitData = new Unit__c();
        unitData.Name = 'Test Unit';
        unitData.Date_Available__c = Date.newInstance(2025, 4, 22);
        unitData.Budget__c = '2.5 lakh to 5 lakh';
        unitData.Saleable_Area__c = 1200;
        unitData.Type_of_Unit__c = 'Shed';
        unitData.Unit_Status__c = 'Available';
        unitData.Size_Range__c = '10000 - 25000';
        
        units.add(unitData);
        insert unitData;
        
        Unit__c unit = [
            Select Id, Unit_Status__c, Contact_Number__c,
                   Name, Date_Available__c, Budget__c,
                   Saleable_Area__c, Type_of_Unit__c,
                   Unit_Number__c
            From Unit__c
            Where Id = :unitData.Id
        ];
       
        Test.startTest();
        
        List<Unit__c> result = GetUnitController.getDataByUnitNumber(
            unit.Unit_Number__c,
            unit.Name,
            unit.Type_of_Unit__c
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void getUnitsByCrane() {
        
        List<Unit__c> units = new List<Unit__c>();
        
        Unit__c unitData = new Unit__c();
        unitData.Name = 'Test Unit';
        unitData.Date_Available__c = Date.newInstance(2025, 4, 22);
        unitData.Budget__c = '2.5 lakh to 5 lakh';
        unitData.Saleable_Area__c = 1200;
        unitData.Type_of_Unit__c = 'Shed';
        unitData.Unit_Status__c = 'Available';
        unitData.Size_Range__c = '10000 - 25000';
        unitData.Unit_Category__c ='SIPCOT';
        unitData.EoT_Crane_Provision__c = 'Yes';
        
        units.add(unitData);
        insert unitData;        
        
        Unit__c unit = [
            Select Id, Unit_Status__c, EoT_Crane_Provision__c,
                   Unit_Category__c, Contact_Number__c,
                   Name, Date_Available__c, Budget__c,
                   Saleable_Area__c, Type_of_Unit__c,
                   Unit_Number__c
            From Unit__c
            Where Id = :unitData.Id
        ];
       
        Test.startTest();
        
        List<Unit__c> result = GetUnitController.getUnitsByCrane(
            unit.Unit_Category__c,
            unit.EoT_Crane_Provision__c
        );
        
        Test.stopTest();
    }
}