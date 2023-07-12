public with sharing class TestTriggerHandler {
    public static void checkProposals(Map<Id, Test_Object__c> newMap, Map<Id, Test_Object__c> oldMap){
        List<Id> simplyProposalIds = new List<Id>();

        for (Id tId : newMap.keySet()) {
            Test_Object__c oldTestObj = oldMap.get(tId);
            Test_Object__c newTestObj = newMap.get(tId);

            if (oldTestObj.Check_Field__c) {
                simplyProposalIds.add(tId);
            }
        }
        if(simplyProposalIds.size() > 0){
            System.debug('----simplyProposalIds: \n' + simplyProposalIds);
            System.debug('----simplyProposalIds SIZE: ' + simplyProposalIds.size());
            processRecords(simplyProposalIds);
        }
    }

    public static void processRecords(List<Id> propIds) {
        Integer chunkSize = 50; // Set the desired chunk size

        for (Integer i = 0; i < propIds.size(); i += chunkSize) {
            List<Id> chunk = new List<Id>();

            for (Integer j = i; j < Math.min(i + chunkSize, propIds.size()); j++) {
                chunk.add(propIds[j]);
            }
            System.debug('====chunk.size(): ' + chunk.size());
            System.enqueueJob(new TestObjectQueable(chunk));
        }
    }
}