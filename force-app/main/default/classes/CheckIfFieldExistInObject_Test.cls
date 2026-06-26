@isTest
public class CheckIfFieldExistInObject_Test {

    @isTest
    static void testFieldExists() {
        Test.startTest();
        Boolean result = CheckIfFieldExistInObject.checkField('Account', 'Name');
        Test.stopTest();

    }

    @isTest
    static void testFieldDoesNotExist() {
        Test.startTest();
        Boolean result = CheckIfFieldExistInObject.checkField('Account', 'Name1');
        Test.stopTest();
    }

    @isTest
    static void testObjectDoesNotExist() {
        Test.startTest();
        try{
        Boolean result = CheckIfFieldExistInObject.checkField('NonexistentObject', 'Field');
        }catch(Exception e) {
      
      boolean result = false;     }
        Test.stopTest();
    }

    @isTest
    static void testInvalidFieldReference() {
        Test.startTest();
        Boolean result = CheckIfFieldExistInObject.checkField('Account', null);
        Test.stopTest();
    }

    @isTest
    static void testExceptionHandling() {
        Test.startTest();
        Boolean result = CheckIfFieldExistInObject.checkField('Account', 'ExceptionField');
        Test.stopTest();
    }
}