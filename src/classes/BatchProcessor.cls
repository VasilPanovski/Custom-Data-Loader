/**
* @author        : Vasil Panovski
* @date          : November 19, 2019
* @description   : Batchable class that encapsulates logic for mass data upload
*/
global class BatchProcessor implements Database.Batchable<SObject> {

    SObject[] source;

    global BatchProcessor(SObject[] source) {
        this.source = source;
    }

    global Iterable<SObject> start(Database.BatchableContext bc) {
        BatchSObjectIterator iterator = new BatchSObjectIterator(source);
        return iterator;
    }

    global void execute(Database.BatchableContext bc, SObject[] scope) {
        try {
            Database.insert(scope, false);
        } catch (Exception ex) {
            ErrorLogger.logError(ex.getMessage(), 'BatchProcessor', 'execute');
        }

    }

    global void finish(Database.BatchableContext bc) {

    }
}