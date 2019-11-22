@IsTest
public with sharing class DataImportServiceTest {

    @IsTest
    public static void testDataImportWithValidDate() {

        List<Object> objectsToInsert = getAccountObjects(5);
        String jsonObjects = JSON.serialize(objectsToInsert);

        Test.startTest();
            String returnValue = DataImportService.importDataFromJSONInput(jsonObjects);
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(5, accounts.size());
        System.assertEquals(String.format(Constants.DATA_IMPORTED_MESSAGE_FORMAT, new List<Integer>{5, 0}), returnValue);
    }


    @IsTest
    public static void testPartialDataImportSucceeded() {

        List<Object> objectsToInsert = getAccountObjects(3);
        objectsToInsert.addAll(getOpportunityObjects(1));
        String jsonObjects = JSON.serialize(objectsToInsert);

        Test.startTest();
        String returnValue = DataImportService.importDataFromJSONInput(jsonObjects);
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account];
        List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
        System.assertEquals(3, accounts.size() + opportunities.size());
        System.assertEquals(String.format(Constants.DATA_IMPORTED_MESSAGE_FORMAT, new List<Integer>{3, 1}), returnValue);
    }


    @IsTest
    public static void testBatchDataImport() {

        List<Object> objectsToInsert = getAccountObjects(2001);
        List<Object> batch2 = new List<Object>(objectsToInsert);
        List<Object> batch3 = new List<Object>(objectsToInsert);
        List<Object> batch4 = new List<Object>(objectsToInsert);
        List<Object> batch5 = new List<Object>(objectsToInsert);
        objectsToInsert.addAll(batch2);
        objectsToInsert.addAll(batch3);
        objectsToInsert.addAll(batch4);
        objectsToInsert.addAll(batch5);

        String jsonObjects = JSON.serialize(objectsToInsert);

        Test.startTest();
        String returnValue = DataImportService.importDataFromJSONInput(jsonObjects);
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account];

        System.assertEquals(10005, accounts.size());
        System.assertEquals(Constants.BATCH_PROCESSED_MESSAGE, returnValue);
    }


    private static List<Object> getAccountObjects(Integer objectCount) {
        List<Object> accObjects = new List<Object>();
        for (Integer i = 1; i <= objectCount; i++) {
            Map<String, Object> accObjectTokens = new Map<String, Object>();
            Map<String, Object> accFieldsObjectTokens = new Map<String, Object>();
            accFieldsObjectTokens.put('Name', 'Test ' + i);
            accFieldsObjectTokens.put('Phone', '1100' + i);
            accFieldsObjectTokens.put('NumberOfEmployees', 10);
            accFieldsObjectTokens.put('AnnualRevenue', 10000);

            accObjectTokens.put('SObjectName', 'Account');
            accObjectTokens.put('Fields', accFieldsObjectTokens);
            accObjects.add(accObjectTokens);
        }

        return accObjects;
    }

    private static List<Object> getOpportunityObjects(Integer objectCount) {
        List<Object> oppObjects = new List<Object>();
        for (Integer i = 1; i <= objectCount; i++) {
            Map<String, Object> oppObjectTokens = new Map<String, Object>();
            Map<String, Object> oppFieldsObjectTokens = new Map<String, Object>();
            oppFieldsObjectTokens.put('Name', 'O' + i);
            oppFieldsObjectTokens.put('StageName', 'Prospecting');
            oppFieldsObjectTokens.put('TotalOpportunityQuantity', 2);

            oppObjectTokens.put('SObjectName', 'Opportunity');
            oppObjectTokens.put('Fields', oppFieldsObjectTokens);
            oppObjects.add(oppObjectTokens);
        }

        return oppObjects;
    }
}