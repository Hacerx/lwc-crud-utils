@isTest
public with sharing class LwcCrudUtilsTest {

    private static List<Id> INVALID_IDS = new List<Id>{ '001000000000001', '001000000000002' }; // Assuming these IDs do not exist

    private static String EXCEPTION_MESSAGE = 'please contact with your admin';

    @TestSetup
    static void makeData(){
        List<Account> accounts = new List<Account>();

        for(Integer i = 0; i < 100; i++){
            accounts.add(new Account(Name = 'Test Account ' + i));
        }

        insert accounts;
    }
    
    @isTest
    static void testDeleteRecordsEmpty() {
        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.deleteRecords(new List<Id>(), true);
        System.assertEquals(0, results.size());
    }

    
    @isTest
    static void testDeleteRecordsNull() {
        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.deleteRecords(null, true);
        System.assertEquals(0, results.size());
    }

    @isTest
    static void testUpdateRecordsEmpty() {
        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.updateRecords(new List<SObject>(), true);
        System.assertEquals(0, results.size());
    }

    @isTest
    static void testUpdateRecordsNull() {
        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.updateRecords(null, true);
        System.assertEquals(0, results.size());
    }

    @isTest
    static void testInsertRecordsEmpty() {
        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.insertRecords(new List<LwcCrudUtils.RecordInput>(), true);
        System.assertEquals(0, results.size());
    }

    @isTest
    static void testInsertRecordsNull() {
        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.insertRecords(null, true);
        System.assertEquals(0, results.size());
    }

    @isTest
    static void testUpsertRecordsEmpty() {
        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.upsertRecords(new List<Map<String, Object>>(), 'Account', 'Id', true);
        System.assertEquals(0, results.size());
    }

    @isTest
    static void testUpsertRecordsNull() {
        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.upsertRecords(null, 'Account', 'Id', true);
        System.assertEquals(0, results.size());
    }

    @isTest
    static void testUpserRecordsExceptionApiName() {
        try{
            List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.upsertRecords(new List<Map<String, Object>>(), null, 'Id', true);
        }catch(Exception e){
            System.assert(e.getMessage().contains('apiName'), 'Exception should be thrown for null API name');
        }

        try{
            List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.upsertRecords(new List<Map<String, Object>>(), '', 'Id', true);
        }catch(Exception e){
            System.assert(e.getMessage().contains('externalId'), 'Exception should be thrown for null externalId');
        }
    }

    @isTest
    static void testUpsertRecordsExceptionExternalId() {
        try{
            List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.upsertRecords(new List<Map<String, Object>>(), 'Account', null, true);
        }catch(Exception e){
            System.assert(e.getMessage().contains('externalId'), 'Exception should be thrown for null externalId');
        }

        try{
            List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.upsertRecords(new List<Map<String, Object>>(), 'Account', '', true);
        }catch(Exception e){
            System.assert(e.getMessage().contains('externalId'), 'Exception should be thrown for empty externalId');
        }
    }

    @isTest
    static void testDeleteRecords() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id FROM Account]);
        
        Integer initialSize = accountMap.size();
        System.assert(initialSize > 0, 'There should be accounts to delete');

        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.deleteRecords(new List<Id>(accountMap.keySet()), true);
        System.assertEquals(initialSize, results.size(), 'Number of delete results should match number of accounts deleted');

        for(LwcCrudUtils.DMLResult result : results) {
            System.assert(result.success, 'All delete operations should be successful');
        }

        accountMap = new Map<Id, Account>([SELECT Id FROM Account]);
        System.assertEquals(0, accountMap.size(), 'All accounts should have been deleted');
    }

    @isTest
    static void testDeleteRecordsException() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id FROM Account]);

        try{
            // Simulate an exception by trying to delete a record that doesn't exist
            List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.deleteRecords(INVALID_IDS, true);
        }catch(Exception e){
            System.assert(e.getMessage().contains(EXCEPTION_MESSAGE), 'Exception message should indicate an error occurred during deletion');
        }
    }

    @isTest
    static void testDeleteRecordsCatchException() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id FROM Account]);

        // Simulate an exception by trying to delete a record that doesn't exist
        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.deleteRecords(INVALID_IDS, false);

        for(LwcCrudUtils.DMLResult result : results) {
            System.assert(!result.success, 'Delete operation should not be successful for invalid IDs');
        }
    }

    @isTest
    static void testUpdateRecords() {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assert(accounts.size() > 0, 'There should be accounts to update');

        for(Account acc : accounts) {
            acc.Name = acc.Name + ' Updated';
        }

        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.updateRecords(accounts, true);
        System.assertEquals(accounts.size(), results.size(), 'Number of update results should match number of accounts updated');

        for(LwcCrudUtils.DMLResult result : results) {
            System.assert(result.success, 'All update operations should be successful');
        }

        // Verify that the accounts were updated
        List<Account> updatedAccounts = [SELECT Id, Name FROM Account WHERE Id IN :accounts];
        for(Account acc : updatedAccounts) {
            System.assert(acc.Name.endsWith(' Updated'), 'Account name should have been updated');
        }
    }

    @isTest
    static void testUpdateRecordsException() {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assert(accounts.size() > 0, 'There should be accounts to update');

        // Simulate an exception by trying to update a record with an invalid field
        for(Account acc : accounts) {
            acc.Name = null; // This will cause a validation error if Name is required
        }

        try{
            List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.updateRecords(accounts, true);
        }catch(Exception e){
            System.assert(e.getMessage().contains(EXCEPTION_MESSAGE), 'Exception message should indicate an error occurred during update');
        }
    }

    @isTest
    static void testUpdateRecordsCatchException() {
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assert(accounts.size() > 0, 'There should be accounts to update');

        for(Account acc : accounts) {
            acc.Name = null; // This will cause a validation error if Name is required
            acc.AccountSource = INVALID_IDS[0]; // Assign an invalid ID to simulate a failure
        }

        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.updateRecords(accounts, false);
        for(LwcCrudUtils.DMLResult result : results) {
            System.assert(!result.success, 'Update operation should not be successful for invalid updates');
        }

        // Verify that the accounts were not updated
        List<Account> unchangedAccounts = [SELECT Id, Name FROM Account WHERE Id IN :accounts];
        for(Account acc : unchangedAccounts) {
            System.assert(!acc.Name.contains(' Updated'), 'Account name should not have been updated due to validation error');
        }
    }

    @isTest
    static void testInsertRecords() {
        // Get actual account
        List<Account> existingAccounts = [SELECT Id FROM Account];

        List<LwcCrudUtils.RecordInput> records = new List<LwcCrudUtils.RecordInput>();
        for(Integer i = 0; i < 10; i++) {
            records.add(new LwcCrudUtils.RecordInput('Account', new Map<String, Object>{ 'Name' => 'Test Account ' + i }));
        }

        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.insertRecords(records, true);
        System.assertEquals(records.size(), results.size(), 'Number of insert results should match number of records inserted');

        for(LwcCrudUtils.DMLResult result : results) {
            System.assert(result.success, 'All insert operations should be successful');
        }

        // Verify that the accounts were inserted
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Test Account %' AND Id NOT IN :existingAccounts];

        System.assertEquals(records.size(), insertedAccounts.size(), 'Number of inserted accounts should match number of records inserted');
    }

    @isTest
    static void testInsertRecordsException() {
        List<LwcCrudUtils.RecordInput> records = new List<LwcCrudUtils.RecordInput>();
        for(Integer i = 0; i < 10; i++) {
            records.add(new LwcCrudUtils.RecordInput('Account', new Map<String, Object>{ 'Name' => null })); // This will cause a validation error
        }

        try{
            List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.insertRecords(records, true);
        }catch(Exception e){
            System.assert(e.getMessage().contains(EXCEPTION_MESSAGE), 'Exception message should indicate an error occurred during insert');
        }
    }

    @isTest
    static void testUpsertRecords() {
        // Get actual account
        List<Account> existingAccounts = [SELECT Id FROM Account];

        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for(Integer i = 0; i < 10; i++) {
            Map<String, Object> recordData = new Map<String, Object>{ 'Name' => 'Test Account ' + i };
            records.add(recordData);
        }

        List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.upsertRecords(records, 'Account', 'Id', true);
        System.assertEquals(records.size(), results.size(), 'Number of upsert results should match number of records upserted');

        for(LwcCrudUtils.DMLResult result : results) {
            System.assert(result.success, 'All upsert operations should be successful');
        }

        // Verify that the accounts were upserted
        List<Account> upsertedAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Test Account %' AND Id NOT IN :existingAccounts];
        System.assertEquals(records.size(), upsertedAccounts.size(), 'Number of upserted accounts should match number of records upserted');
    }

    @isTest
    static void testUpsertRecordsException() {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        for(Integer i = 0; i < 10; i++) {
            Map<String, Object> recordData = new Map<String, Object>{
                'Name' => null // This will cause a validation error
            };
            records.add(recordData);
        }

        try{
            List<LwcCrudUtils.DMLResult> results = LwcCrudUtils.upsertRecords(records, 'Account', 'Id', true);
        }catch(Exception e){
            System.assert(e.getMessage().contains(EXCEPTION_MESSAGE), 'Exception message should indicate an error occurred during upsert');
        }
    }

    @isTest
    static void testGetRecordsEmptyFields() {
        try{
            List<SObject> records = LwcCrudUtils.getRecords(new List<String>(), '', 'Account', '', '', 0);
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('fields must be provided'), 'Exception should be thrown for empty fields');
            return;
        }
        System.assert(false, 'Test should not reach this point if exception is thrown');
    }

    @isTest
    static void testGetRecordsEmptySObject() {
        try{
            List<SObject> records = LwcCrudUtils.getRecords(new List<String>(), '', '', '', '', 0);
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('sobject must be provided'), 'Exception should be thrown for empty fields');
            return;
        }
        System.assert(false, 'Test should not reach this point if exception is thrown');
    }

    @isTest
    static void testGetRecordsFields() {
        List<SObject> records = LwcCrudUtils.getRecords(new List<String>{ 'Id', 'Name' }, '', 'Account', '', 'CreatedDate', 10);
        System.assert(records.size() <= 10, 'Number of records should not exceed the limit');
        
        for(SObject record : records) {
            System.assert(record.Id != null, 'Record ID should not be null');
            System.assert(record.get('Name') != null, 'Record Name should not be null');
        }
    }

    @isTest
    static void testGetRecordsquerySelect() {
        List<SObject> records = LwcCrudUtils.getRecords(new List<String>(), 'Id, Name', 'Account', '', 'CreatedDate', 10);
        System.assert(records.size() <= 10, 'Number of records should not exceed the limit');
        
        for(SObject record : records) {
            System.assert(record.Id != null, 'Record ID should not be null');
            System.assert(record.get('Name') != null, 'Record Name should not be null');
        }
    }

    @isTest
    static void testGetRecordsWhereClause() {
        List<SObject> records = LwcCrudUtils.getRecords(new List<String>{ 'Id', 'Name' }, '', 'Account', 'Name LIKE \'Test Account %\'', 'CreatedDate', 10);
        System.assert(records.size() <= 10, 'Number of records should not exceed the limit');
        
        for(SObject record : records) {
            System.assert(record.Id != null, 'Record ID should not be null');
            System.assert(record.get('Name') != null, 'Record Name should not be null');
        }
    }

    @isTest
    static void testGetRecordsOrderBy() {
        List<SObject> records = LwcCrudUtils.getRecords(new List<String>{ 'Id', 'Name' }, '', 'Account', '', 'CreatedDate DESC', 10);
        System.assert(records.size() <= 10, 'Number of records should not exceed the limit');
        
        for(SObject record : records) {
            System.assert(record.Id != null, 'Record ID should not be null');
            System.assert(record.get('Name') != null, 'Record Name should not be null');
        }
    }

    @isTest
    static void testGetRecordsException() {
        try {
            List<SObject> records = LwcCrudUtils.getRecords(new List<String>{ 'Id', 'Name' }, '', 'InvalidSObject', '', '', 10);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Error getting records, please contact with your admin'), 'Exception should be thrown for invalid SObject');
            return;
        }
        System.assert(false, 'Test should not reach this point if exception is thrown');
    }
}