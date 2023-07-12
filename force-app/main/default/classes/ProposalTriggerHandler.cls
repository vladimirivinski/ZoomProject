public with sharing class ProposalTriggerHandler {

    public static void checkProposals(Map<Id, Proposal__c> newMap, Map<Id, Proposal__c> oldMap) {
        List<Id> simplyProps = new List<Id>();

        for (Id propId : newMap.keySet()) {
            Proposal__c oldProposal       = oldMap.get(propId);
            Proposal__c newProposal       = newMap.get(propId);

            Boolean isBatch               = System.isBatch();
            Boolean isFuture              = System.isFuture();
            Boolean isQueueable           = System.isQueueable();

            Boolean isOldRecordQueued     = oldProposal.Queued__c;
            Boolean isNewRecordQueued     = newProposal.Queued__c;
            Boolean isNewRecordTypeId     = newProposal.RecordTypeId == '0121G000000RlheQAC';

            Boolean isNewRecordForceQueue = newProposal.Force_Queue__c;

            Boolean hasOpportunityId      = oldProposal.Principal_Opportunity_Id__c != null;

            Boolean isNewerThanLaunchDate = newProposal.CreatedDate >= Date.valueOf('2022-07-15 10:00:00');

            Boolean isManualCallout       = newProposal.Manual_Callout__c;
            Boolean wasManualCallout      = oldProposal.Manual_Callout__c;
            Boolean isCommittedStage      = newProposal.Principal_Opportunity_Stage__c == 'Committed';

            Boolean hasStageChanged       = oldProposal.Principal_Opportunity_Stage__c != newProposal.Principal_Opportunity_Stage__c;
            Boolean isStageNotNull        = newProposal.Principal_Opportunity_Stage__c != null;


            if( !simplyProps.contains(propId) && !isBatch && !isFuture && !isQueueable
                &&
                ( !isOldRecordQueued && !isNewRecordQueued && isNewRecordTypeId )
                &&
                ( isNewRecordForceQueue || ( hasOpportunityId || ( ( isNewerThanLaunchDate || ( isManualCallout && !wasManualCallout || isCommittedStage ) ) && ( hasStageChanged && isStageNotNull ) ) ) )
            ) {
                    newProposal.Queued__c = true;
                    newProposal.Force_Queue__c = false;
                    simplyProps.add(propId);
            }
        }

        if (simplyProps.size() > 0) {
            processRecords(simplyProps);
        }
    }

    public static void processRecords(List<Id> propIds) {
        Integer chunkSize = 50; // Set the desired chunk size
        for (Integer i = 0; i < propIds.size(); i += chunkSize) {
            List<Id> chunk = new List<Id>();
            for (Integer j = i; j < Math.min(i + chunkSize, propIds.size()); j++) {
                chunk.add(propIds[j]);
            }
            System.enqueueJob(new SimplyCallout(chunk));
        }
    }
}