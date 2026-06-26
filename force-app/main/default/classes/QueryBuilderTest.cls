@IsTest
public with sharing class QueryBuilderTest {
    
    @TestSetup
    public static void init() {
        createAccount(1);
    }
    
    @IsTest
    public static void testFrom1() {
        List<Account> accounts = (List<Account>) new QueryBuilder('Account')
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testFrom2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testFrom3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(new Account())
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testFrom4() {
        List<Account> accounts = (List<Account>) new QueryBuilder(new Account().getSObjectType())
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testFrom5() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
            .addFrom('Account')
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testFrom6() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
            .addFrom(Account.class)
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testFrom7() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
            .addFrom(new Account())
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testFrom8() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
            .addFrom(new Account().getSObjectType())
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testField1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addField('Name')
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testField2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addField(Account.Name)
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testField3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addField('Id, Name')
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFields(new Account(Name = 'test'))
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields21() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFields('Name')
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields22() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFields('Id, Name')
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields23() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFields('Name, Name')
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields31() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFields(new List<String>{
                'Name'
                    })
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields32() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFields(new List<String>{
                'Id', 'Name'
                    })
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields33() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFields(new List<String>{
                'Name', 'Name'
                    })
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields4() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFields(new Set<String>{
                'Name'
                    })
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields5() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFieldsAll()
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields6() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFieldsAll('Account')
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFields7() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFieldsAllCreatable()
            .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testConditionManager() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.SimpleCondition())
            .preview()
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testSimpleCondition1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.SimpleCondition('Name = \'Account-1\''))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testSimpleCondition2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.SimpleCondition())
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testNullCondition1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.NullCondition('Name').isNull())
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testNullCondition12() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.NullCondition(Account.Name).isNull())
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testNullCondition2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.NullCondition(Account.Name).notNull())
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testCompareCondition1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('Name').eq('Account-1'))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testCompareCondition12() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition(Account.Name).eq('Account-1'))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testCompareCondition2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('Name').ne('Account-1'))
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testCompareCondition3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('NumberOfEmployees').eq(1))
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testCompareCondition31() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('NumberOfEmployees').ne(0))
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testCompareCondition32() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('NumberOfEmployees').gt(0))
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testCompareCondition33() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('NumberOfEmployees').gte(1))
            .endConditions()
            .preview()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testCompareCondition34() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('NumberOfEmployees').lt(0))
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testCompareCondition35() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('NumberOfEmployees').lte(-1))
            .endConditions()
            .preview()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testLikeCondition1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.LikeCondition('Name').likeAnyBoth('ccount-'))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testLikeCondition12() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.LikeCondition(Account.Name).likeAnyBoth('ccount-'))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testLikeCondition2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.LikeCondition('Name').likeAnyLeft('ccount-1'))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testLikeCondition3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.LikeCondition('Name').likeAnyRight('Account-'))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testInCondition01() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('Id').inCollection(new Set<Id>()))
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testInCondition02() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('Id').inCollection(new List<Id>()))
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testInCondition1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('Name').inCollection(new List<String>{
                'Account-1'
                    }))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testInCondition12() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition(Account.Name).inCollection(new List<String>{
                'Account-1'
                    }))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testInCondition2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('Name').inCollection(new Set<String>{
                'Account-1'
                    }))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testInCondition3() {
        Set<Id> accIds = new QueryBuilder('Account').toIdSet();
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('Id').inCollection(accIds))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testInCondition31() {
        List<String> accIds = new List<Id>(new QueryBuilder('Account').toIdSet());
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('Id').inCollection(accIds))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testComplexCondition0() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        System.assertEquals('', complex.toString());
    }
    
    @IsTest
    public static void testComplexCondition1() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.startCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(complex)
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testComplexCondition2() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(complex)
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testComplexCondition3() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.orCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(complex)
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testComplexCondition4() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.NullCondition('Name').notNull())
            .add(complex)
            .setConditionOrder('1' + complex.addOrderIfNotEmpty('AND 2'))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testComplexCondition5() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.NullCondition('Name').notNull())
            .add(complex)
            .setConditionOrder('1' + complex.addOrderIfNotEmpty('AND 2'))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testComplexCondition6() {
        Id accId = new QueryBuilder('Account').toSObject().Id;
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        complex.andCondition(new QueryBuilder.CompareCondition('Id').eq(accId));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(complex)
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testComplexCondition7() {
        Id accId = new QueryBuilder('Account').toSObject().Id;
        createAccount(2);
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-2'));
        complex.orCondition(new QueryBuilder.CompareCondition('Id').eq(accId));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(complex)
            .endConditions()
            .toList();
        System.assertEquals(2, accounts.size());
    }
    
    @IsTest
    public static void testLimit1() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setLimit(-1)
            .toList();
        System.assertEquals(2, accounts.size());
    }
    
    @IsTest
    public static void testLimitSetOffset() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setOffset(-1)
            .toList();
        System.assertEquals(2, accounts.size());
    }
    
    @IsTest
    public static void testLimit2() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setLimit(1)
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testOrder1() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addField('Name')
            .addOrderAsc('Name')
            .toList();
        System.assertEquals('Account-1', accounts[0].Name);
    }
    
    @IsTest
    public static void testAddOrder() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addOrder(
                new QueryBuilder.Order(Account.Id)
                .setSortingOrderAsc()
                .setNullsOrderLast()
                .setSortingOrderDesc()
                .setNullsOrderFirst()
            )
            .addField('Name')
            .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }
    
    @IsTest
    public static void testOrder2() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addField('Name')
            .addOrderDesc('Name')
            .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }
    
    @IsTest
    public static void testOrder3() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addField('Name')
            .addOrderAsc('Name')
            .addOrderAsc('Id')
            .toList();
        System.assertEquals('Account-1', accounts[0].Name);
    }
    
    @IsTest
    public static void testOrder4() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addField('Name')
            .addOrderDesc('Name')
            .addOrderDesc('Id')
            .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }
    
    @IsTest
    public static void testPreview() {
        new QueryBuilder(Account.class)
            .preview();
    }
    
    @IsTest
    public static void testPreviewCount() {
        new QueryBuilder(Account.class)
            .previewCount();
    }
    
    @IsTest
    public static void testToString() {
        String queryString = new QueryBuilder(Account.class)
            .toString();
        System.assertEquals('SELECT Id \nFROM Account', queryString);
    }
    
    @IsTest
    public static void testToCountString() {
        String queryString = new QueryBuilder(Account.class)
            .toStringCount();
        System.assertEquals('SELECT count() FROM Account', queryString);
    }
    
    @IsTest
    public static void testToCountString2() {
        String queryString = new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('Name').eq('Account-1'))
            .endConditions()
            .toStringCount();
        System.assertEquals('SELECT count() FROM Account WHERE Name = \'Account-1\'', queryString);
    }
    
    @IsTest
    public static void testResetResult() {
        QueryBuilder accountQueryBuilder = new QueryBuilder('Account');
        List<Account> accounts = (List<Account>) accountQueryBuilder
            .toList();
        System.assertEquals(1, accounts.size());
        createAccount(2);
        accounts = (List<Account>) accountQueryBuilder.toList();
        System.assertEquals(1, accounts.size());
        accountQueryBuilder.resetResult();
        accounts = (List<Account>) accountQueryBuilder.toList();
        System.assertEquals(2, accounts.size());
    }
    
    @IsTest
    public static void testToMap1() {
        Map<Id, SObject> accounts = new QueryBuilder('Account')
            .addField('Name')
            .toMap();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testToMap1AddSubQuery() {
        Map<Id, SObject> accounts = new QueryBuilder(Account.class)
            .addSubQuery('SELECT Id FROM Contacts')
            .toMap();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testToMap1QueryBuilder() {
        Map<Id, SObject> accounts = new QueryBuilder(Account.class)
            .addSubQuery(new QueryBuilder('Contacts'))
            .toMap();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testToMap1Else() {
        Map<Id, SObject> accounts = new QueryBuilder('Account')
            .addField('Description')
            .toMap();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testToMap2() {
        Map<Id, Account> accounts = new Map<Id, Account>();
        new QueryBuilder('Account')
            .addField('Name')
            .toMap(accounts);
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testToSObject() {
        Account account = (Account) new QueryBuilder('Account')
            .toSObject();
        System.assertNotEquals(null, account);
    }
    
    @IsTest
    public static void testToSObject2() {
        SObject account = (Account) new QueryBuilder('Account')
            .addConditions()
            .add(new QueryBuilder.NullCondition('Name').isNull())
            .endConditions()
            .toSObject();
        System.assertEquals(null, account);
    }
    
    @IsTest
    public static void testToIdSet() {
        Set<Id> accountIds = new QueryBuilder('Account')
            .toIdSet();
        System.assertEquals(1, accountIds.size());
    }
    
    @IsTest
    public static void testExtractIds() {
        final Id ACCOUNT_ID = new QueryBuilder('Account').toSObject().Id;
        createContact(ACCOUNT_ID);
        Set<Id> extractedIds = new QueryBuilder('Contact')
            .addField('AccountId')
            .extractIds('AccountId');
        System.assertEquals(1, extractedIds.size());
        System.assert(extractedIds.contains(ACCOUNT_ID));
    }
    
    @IsTest
    public static void testClone1() {
        QueryBuilder qb1 = new QueryBuilder('Account');
        System.assertEquals('SELECT Id \nFROM Account', qb1.toString());
        QueryBuilder qb2 = qb1.cloneQueryBuilder();
        qb2.addField('Name');
        qb1.resetResult();
        System.assertEquals('SELECT Id \nFROM Account', qb1.toString());
        System.assertEquals('SELECT Name \nFROM Account', qb2.toString());
    }
    
    @IsTest
    public static void testClone2() {
        QueryBuilder qb1 = new QueryBuilder('Account');
        qb1.toList();
        QueryBuilder qb2 = qb1.cloneQueryBuilder(true);
        createAccount(2);
        System.assertEquals(qb1.toList(), qb2.toList());
    }
    
    @IsTest
    public static void testStub1() {
        final String EXPECTED_SOQL = 'SELECT Name FROM Account';
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubToString(EXPECTED_SOQL)
            .applyStub();
        System.assertEquals(EXPECTED_SOQL, stubbedQueryBuilder.toString());
    }
    
    @IsTest
    public static void testStub1Else() {
        final String EXPECTED_SOQL = 'SELECT Name FROM Account';
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubtoStringCount(EXPECTED_SOQL)
            .applyStub();
        System.assertEquals(EXPECTED_SOQL, stubbedQueryBuilder.toStringCount());
    }
    
    @IsTest
    public static void testStub1Else2() {
        Account acc = [SELECT  NumberOfEmployees FROM Account LIMIT 1];
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubToCount(acc.NumberOfEmployees)
            .applyStub();
        System.assertEquals(acc.NumberOfEmployees, stubbedQueryBuilder.toCount());
    }
    
    @IsTest
    public static void testStub1Else3() {
        // Map<Id, SObject> toMapResult = new Map<Id, SObject> ();
        account acc= new account ();
        acc.Name ='test';
        insert acc;
        // toMapResult.put(acc.id,acc);
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubToSObject(acc)
            .applyStub();
        
        System.assertEquals(acc, stubbedQueryBuilder.toSobject());
    }
    
    @IsTest
    public static void testStub1ElseTest() {
        set<id> accountid = new set<id>();
        account acc= new account ();
        acc.Name='ttest';
        insert acc;
        /* opportunity opp = new opportunity();
opp.Name='test';
opp.CloseDate= system.today();
opp.StageName='In Progress';
opp.AccountId=acc.id;
insert opp;*/
        accountid.add(acc.id);
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubExtractIds(accountid)
            .applyStub();
        // System.assertEquals(accountid, stubbedQueryBuilder.extractIds());
    }
    
    @IsTest
    public static void testStub3ElseTest() {
        List<account> acc =[Select Name from account ];
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubExtractField(acc)
            .applyStub();
        
        //  System.assertEquals(acc, stubbedQueryBuilder.extractField());
    }
    
    @IsTest
    public static void testStub2ElseTest() {
        set<id> accountid = new set<id>();
        account acc= new account ();
        acc.Name ='test';
        insert acc;
        accountid.add(acc.Id);
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubToIdSet(accountid)
            .applyStub();
        System.assertEquals(accountid, stubbedQueryBuilder.toIdSet());
    }
    
    @IsTest
    public static void stubToMapTest() {
        Map<Id, SObject> mapToFill = new Map<Id, SObject>();
        account acc= new account ();
        acc.Name ='test';
        insert acc;
        mapToFill.put(acc.id,acc);
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubToMap(mapToFill)
            .applyStub();
        
        System.assertEquals(mapToFill, stubbedQueryBuilder.toMap());
    }
    
    public static void stubToMapElse() {
        Map<Id, SObject> mapToFill = new Map<Id, SObject>();
        account acc= new account ();
        acc.Name ='test';
        insert acc;
        mapToFill.put(acc.id,acc);
        System.assertEquals(null, null);
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubToMap(mapToFill)
            .applyStub();
        System.assertEquals(mapToFill, stubbedQueryBuilder.toMap());
    }
    
    @IsTest
    public static void stubToSObjectTest() {
        account acc =[Select Name from account LIMIT 1 ];
        
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubToSObject(acc)
            .applyStub();
        System.assertEquals(acc, stubbedQueryBuilder.toSObject());
    }
    
    @IsTest
    public static void testStub1Else4() {
        Map<Id, SObject> toMapResult = new Map<Id, SObject> ();
        account acc= new account ();
        acc.Name ='test';
        insert acc;
        toMapResult.put(acc.id,acc);
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubToMap(toMapResult)
            .applyStub();
        System.assertEquals(toMapResult, stubbedQueryBuilder.toMap());
    }
    
    @IsTest
    public static void testStub1Else41() {
        Map<Id, SObject> toMapFillResult = new Map<Id, SObject> ();
        account acc= new account ();
        acc.Name ='test';
        insert acc;
        toMapFillResult.put(acc.id,acc);
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubToMap(toMapFillResult)
            .applyStub();
        
        System.assertEquals(toMapFillResult, stubbedQueryBuilder.toMap());
    }
    
    @IsTest
    public static void testStub2() {
        QueryBuilder stubbedQueryBuilder = new QueryBuilder(Account.class)
            .buildStub()
            .addStubToList(new List<Account>{
                new Account(Name = 'Stubbed-Account')
                    })
            .applyStub();
        List<Account> accounts = (List<Account>) stubbedQueryBuilder.toList();
        System.assertEquals(1, accounts.size());
        System.assertEquals('Stubbed-Account', accounts[0].Name);
    }
    
    //Utility methods
    private static Account createAccount(Integer i) {
        Account result = new Account();
        result.Name = 'Account-' + i;
        result.NumberOfEmployees = 0;
        insert result;
        return result;
    }
    
    private static Contact createContact(Id accId) {
        Contact result = new Contact();
        result.LastName = 'Contact-' + accId;
        result.AccountId = accId;
        result.Email = 'email' + accId + '@example.com';
        result.Description = accId;
        insert result;
        return result;
    }
    
    @IsTest
    public static void testFieldsType() {
        Type t = Type.forName('Account');
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFieldsAll(t)
            .toList();
        System.assertEquals(1, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testAddFieldsAllCreatable() {
        Type t = Type.forName('Account');
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFieldsAllCreatable(t)
            .toList();
        System.assertEquals(1, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void addFieldsAllUpdatableTest() {
        Type t = Type.forName('Account');
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFieldsAllUpdatable(t)
            .toList();
        System.assertEquals(1, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testFieldsSObject() {
        Account a = new Account ( Name  ='acc1');
        insert a;
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFieldsAll(a)
            .toList();
        System.assertEquals(2, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testaAddField2() {
        Account a = new Account ( Name  ='acc1');
        insert a;
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFieldsAllCreatable(a)
            .toList();
        System.assertEquals(2, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void addFieldsTest() {
        Account a = new Account ( Name  ='acc1');
        insert a;
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFieldsAllUpdatable()
            .toList();
        System.assertEquals(2, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testAddField() {
        Account a = new Account ( Name  ='acc1');
        insert a;
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addFieldsAllUpdatable(a)
            .toList();
        System.assertEquals(2, accounts.size());
    }
    
    @IsTest
    public static void addConditionsWithOTest() {
        Id accId = new QueryBuilder('Account').toSObject().Id;
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        complex.andCondition(new QueryBuilder.CompareCondition('Id').eq(accId));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditionsWithOrder('1')
            .add(complex)
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }    
    
    @IsTest
    public static void testAddOrderAsc2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addOrderAsc(Account.Name)
            .toList();
        System.assertEquals(1, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testaAddOrderAsc2else() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addOrderDesc(Account.Name)
            .toList();
        System.assertEquals(1, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testAddOrderDesc2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addOrderDesc(Account.Name)
            .toList();
        System.assertEquals(1, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testAddGroupBy1() {
        List<AggregateResult> accounts = (List<AggregateResult>) new QueryBuilder(Account.class)
            .addGroupBy(new List<String>{
                'Id'
                    })
            .toList();          
        System.assertEquals(1, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
        
    }
    
    @IsTest
    public static void testFieldAddGroupBy2() {
        List<AggregateResult> accounts = (List<AggregateResult>) new QueryBuilder(Account.class)
            .addGroupBy(new List<String>{
                'id'
                    })
            .toList();
        System.assertEquals(1, accounts.size());
        // System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testSetForView() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setForView(false)
            .toList();
        System.assertEquals(1, accounts.size());
        //  System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testSetForView2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setForView()
            .toList();
        System.assertEquals(1, accounts.size());
        //  System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testSetForReference() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setForReference(false)
            .toList();
        System.assertEquals(1, accounts.size());
        //  System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testSetForReference2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setForReference()
            .toList();
        System.assertEquals(1, accounts.size());
        //  System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testSetUpdateTracking() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setUpdateTracking(false)
            .toList();
        System.assertEquals(1, accounts.size());
        //  System.assertNotEquals(null, accounts[0].Name);
    }
    
    @IsTest
    public static void testSetUpdateViewStat() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setUpdateViewstat(false)
            .toList();
        System.assertEquals(1, accounts.size());
        //  System.assertNotEquals(null, accounts[0].Name);
    }
    
    
    @IsTest
    public static void testSetCheckCRUDAndFLS() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setCheckCRUDAndFLS(false)
            .toList();
        System.assertEquals(1, accounts.size());
        
    }
    
    @IsTest
    public static void testSetCheckCRUDAndFLS2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setCheckCRUDAndFLS()
            .toList();
        System.assertEquals(1, accounts.size());
        
    }
    
    @IsTest
    public static void testSetWithSecurityEnforced2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setWithSecurityEnforced()
            .toList();
        System.assertEquals(1, accounts.size());
        
    }
    
    
    @IsTest
    public static void testSetCheckCRUD() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setCheckCRUD()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testSetCheckFLS() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .setCheckFLS()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testCompareCondition3Test() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('AccountSource').eq('Web'))
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testCompareConditionneTest() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.CompareCondition('AccountSource').ne('Web'))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testNotLikeAnyBoth3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.LikeCondition('Name').notLikeAnyBoth('Account-'))
            .endConditions()
            .toList();
        System.assertEquals(0, accounts.size());
    }
    
    @IsTest
    public static void testInConditionElse() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('Name').inCollection(new List<SObject>()))
            .endConditions()
            .toList();
        System.assert(accounts.isEmpty());
    }
    
    @IsTest
    public static void testInConditionDecimal() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('Type').inCollection(new List<PicklistEntry>()))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testInConditionNotIn() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('').notIn(new Set<String>()))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testInConditionNotInList() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('').notIn(new List<String>()))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    }
    
    @IsTest
    public static void testInConditionQueryBuilder() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
            .addConditions()
            .add(new QueryBuilder.InCondition('').notIn(new QueryBuilder('Contacts')))
            .endConditions()
            .toList();
        System.assertEquals(1, accounts.size());
    } 
}