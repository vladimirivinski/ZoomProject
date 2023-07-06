trigger ProposalTrigger on Proposal__c (before update) {

    String setMethod;
    List<Id> simplyProps = new List<Id>();
    
    for(Id propId : Trigger.newMap.keySet()){
        System.debug(System.isQueueable());
        //If proposal is from Principal, is not currently queued, and is either created after API launch or a Manual Callout, queue for API Callout
        if(!simplyProps.contains(propId) &&
           System.IsBatch() == false && System.isFuture() == false && System.isQueueable() == false &&
           (Trigger.oldMap.get( propId ).Queued__c == false && Trigger.newMap.get( propId ).Queued__c == false && Trigger.newMap.get( propId ).recordtypeId == '0121G000000RlheQAC') &&
           ((Trigger.newMap.get( propId ).Force_Queue__c == true) ||
           (Trigger.oldMap.get( propId ).Principal_Opportunity_Id__c != null || 
           ((Trigger.newMap.get( propId ).CreatedDate >= Date.valueOf('2022-07-15 10:00:00') || 
           (Trigger.newMap.get( propId ).Manual_Callout__c == true && Trigger.oldMap.get( propId ).Manual_Callout__c == false || 
           Trigger.newMap.get( propId ).Principal_Opportunity_Stage__c == 'Committed')) &&
           (Trigger.oldMap.get( propId ).Principal_Opportunity_Stage__c != Trigger.newMap.get( propId ).Principal_Opportunity_Stage__c && 
            Trigger.newMap.get( propId ).Principal_Opportunity_Stage__c != null))))){
                Trigger.newMap.get( propId ).Queued__c = true;
                Trigger.newMap.get( propId ).Force_Queue__c = false;
           		simplyProps.add(propId);             
        }
        if(!simplyProps.isEmpty()){
            //If Proposal is eligible based on the above criteria, send to SimplyCallout Class
            Proposal__c prop = new Proposal__c();
            for(Id propQueue : simplyProps){
            }
            ID jobID = System.enqueueJob(new SimplyCallout(simplyProps));
            System.debug(Datetime.now());
        }
    }
}