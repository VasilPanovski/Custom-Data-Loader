/**
* @author        : Vasil Panovski
* @date          : November 19, 2019
* @description   : Service class that encapsulates logic for custom data import
*/
public with sharing class DataImportService {

    /**
    * @description Method to evaluate JSON data deserialization to SObjects and insert the same
    * @param jsonInput this is the JSON representation of the objects.
    */
    public static String importDataFromJSONInput(String jsonInput) {

        // return if the JSON string is invalid or empty
        if (String.isEmpty(jsonInput) || !jsonInput.contains('SObjectName')) {
            return Constants.INVALID_JSON_MESSAGE;
        }

        String returnMessage;
        try {
            // deserialize the json to Objects
            List<Object> objList = (List<Object>)JSON.deserializeUntyped(jsonInput);

            List<SObject> sObjectsToInsert = new List<SObject>();
            for (Object obj : objList) {

                // deserialize the object
                String objJsonString = JSON.serialize(obj);
                Map<String, Object> objectTokens = (Map<String, Object>) JSON.deserializeUntyped(objJsonString);

                // deserialize the object fields
                String objFieldsJSONString = JSON.serialize(objectTokens.get('Fields'));
                Map<String, Object> fieldTokens = (Map<String, Object>) JSON.deserializeUntyped(objFieldsJSONString);

                // create instance of SObject from provided type
                Type t = Type.forName(String.valueOf(objectTokens.get('SObjectName')));
                SObject sObjectToInsert = (SObject) t.newInstance();

                // add the valid fields the the SObject instance
                for (String fieldName : fieldTokens.keySet()) {
                    if (isObjectFieldValid(fieldTokens.get(fieldName))) {
                        sObjectToInsert.put(fieldName, fieldTokens.get(fieldName));
                    }
                }

                sObjectsToInsert.add(sObjectToInsert);
            }

            // Process the records with Batch job if the records are more than max dml records per transaction
            if (sObjectsToInsert.size() >= 10000) {
                if (!Test.isRunningTest()) {
                    BatchProcessor batchProcessor = new BatchProcessor(sObjectsToInsert);
                    Database.executeBatch(batchProcessor, 2000);
                    return Constants.BATCH_PROCESSED_MESSAGE;
                }
            }

            Integer failedRecordsCount = 0;
            Integer succeededRecordsCount = 0;

            List<Database.SaveResult> saveResults = Database.insert(sObjectsToInsert, false);
            for (Database.SaveResult sr : saveResults) {
                if (sr.isSuccess()) {
                    succeededRecordsCount++;
                }
                else {
                    failedRecordsCount++;
                }
            }

            returnMessage = String.format(Constants.DATA_IMPORTED_MESSAGE_FORMAT, new List<Integer>{succeededRecordsCount, failedRecordsCount});
        } catch (Exception ex) {
            ErrorLogger.logError(ex.getMessage(), 'DataImportService', 'importDataFromJSONInput');
            returnMessage = String.format(Constants.DATA_IMPORTED_MESSAGE_FORMAT, new List<Integer>{0, 0});
        }

        return returnMessage;
    }

    private static Boolean isObjectFieldValid(Object o) {
        if(o instanceof SObject || o instanceof Boolean || o instanceof Id ||
                o instanceof String || o instanceof Blob || o instanceof Date ||
                o instanceof Integer || o instanceof Long || o instanceof Decimal || o instanceof Double) {
            return true;
        }

        return false;
    }
}