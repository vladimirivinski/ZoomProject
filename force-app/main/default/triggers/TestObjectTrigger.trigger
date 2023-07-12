trigger TestObjectTrigger on Test_Object__c (before update) {
	// List<Id> propsLst = new List<Id>();

	// for (Id tId : Trigger.newMap.keySet()) {
	// 	Test_Object__c oldTestObj = Trigger.oldMap.get(tId);
	// 	Test_Object__c newTestObj = Trigger.newMap.get(tId);

	// 	if (oldTestObj.Check_Field__c) {
	// 		propsLst.add(tId);
	// 	}
	// }

	// if (!propsLst.isEmpty()) {
	// 	System.enqueueJob(new TestObjectQueable(propsLst));
	// }

    if (Trigger.isBefore && Trigger.isUpdate) {
        TestTriggerHandler.checkProposals(Trigger.newMap, Trigger.oldMap);
        System.debug('TRIGGER FIRE ########');
    }
}