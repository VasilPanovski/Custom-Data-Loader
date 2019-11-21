/**
* @author        : Vasil Panovski
* @date          : November 19, 2019
* @description   : Service class that encapsulates logic for logging error in custom object
*/
public with sharing class ErrorLogger {

    /**
    * @description Method to evaluate JSON data deserialization to SObjects and insert the same
    * @param errorMessage this is the exception getMessage() return value.
    * @param className this is the name of the class the error is thrown.
    * @param methodName this is the name of the method the error is thrown.
    */
    public static void logError(String errorMessage, String className, String methodName) {

        Error_Log__c log = new Error_Log__c();
        log.Error_Message__c = errorMessage;
        log.Class_Name__c = className;
        log.Method_Name__c = methodName;
        log.Log_Time__c=System.now();
        log.User__c = UserInfo.getUserId();

        Database.insert(log);
    }
}