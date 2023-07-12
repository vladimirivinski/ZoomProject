trigger ProposalTrigger on Proposal__c(before update) {

	if(Trigger.isUpdate && Trigger.isBefore){
		ProposalTriggerHandler.checkProposals(Trigger.newMap, Trigger.oldMap);
	}

	// List<Id> simplyProps = new List<Id>();

	// for (Id propId : Trigger.newMap.keySet()) {
	// 	Proposal__c oldProposal = Trigger.oldMap.get(propId);
	// 	Proposal__c newProposal = Trigger.newMap.get(propId);

	// 	// Add your conditions or criteria to identify the records to be queued for the API callout
	// 	if (!simplyProps.contains(propId) && !oldProposal.Queued__c && !newProposal.Queued__c && newProposal.RecordTypeId == '0121G000000RlheQAC' &&
	// 		(newProposal.Force_Queue__c ||
    //             (oldProposal.Principal_Opportunity_Id__c != null ||
    //                 ((newProposal.CreatedDate >= Date.valueOf('2022-07-15 10:00:00')  || newProposal.Principal_Opportunity_Stage__c == 'Committed') ||
    //                 (newProposal.Manual_Callout__c && !oldProposal.Manual_Callout__c) &&
    //                 (oldProposal.Principal_Opportunity_Stage__c != newProposal.Principal_Opportunity_Stage__c && newProposal.Principal_Opportunity_Stage__c != null)
    //                 )
    //             )
    //         )
	// 	) {
	// 		newProposal.Queued__c = true;
	// 		newProposal.Force_Queue__c = false;
	// 		simplyProps.add(propId);
	// 	}
	// }

	// if (!simplyProps.isEmpty()) {
	// 	System.enqueueJob(new SimplyCallout(simplyProps));
	// }
}