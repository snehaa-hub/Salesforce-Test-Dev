@isTest
public class ConvertLeadToEnquiry_Test {
    @isTest
    static void ReqTestMethod(){
        Lead ld = new Lead();
        ld.LastName = 'Head';
        ld.Company = 'Manras';
        ld.Status = 'Qualified';
        ld.FirstName = 'Bloom';
        ld.Email = 'test@test321.com';
        ld.Phone = '8295829586';
        insert ld;
    }
}