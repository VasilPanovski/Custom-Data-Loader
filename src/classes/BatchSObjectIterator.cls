/**
* @author        : Vasil Panovski
* @date          : November 19, 2019
* @description   : Iterator class that encapsulates logic for custom SObject iteration
* @usedBy        : BatchProcessor class
*/
global class BatchSObjectIterator implements Iterator<SObject>, Iterable<SObject> {

    SObject[] source;

    global Iterator<SObject> iterator() {
        return this;
    }

    global BatchSObjectIterator(SObject[] source) {
        this.source = source;
    }

    global SObject next() {
        return source.remove(0);
    }

    global Boolean hasNext() {
        return source != null && !source.isEmpty();
    }
}