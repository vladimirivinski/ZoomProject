public class ActivePlanAccountsUpdaterBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id FROM Account');
    }

    public void execute(Database.BatchableContext context, List<Account> scope) {
        // Query for the latest Active Plan__c record related to each Account record in the scope
        Map<Id, Plan__c> latestActiveIdPlanMap = new Map<Id, Plan__c>();
        List<Account> updatedAccount = new List<Account>(); 
        for (Account acc : [SELECT Id, Name,
                                    Status__c,
                                    Custodian__c,
                                    Fund_List__c,
                                    Service_Option__c,
                                    Safe_Harbor__c,
                                    (
                                    SELECT Id, Name, 
                                            Status__c, 
                                            Custodian__c,
                                            Fund_List__c,
                                            Service_Option__c,
                                            Safe_Harbor__c,
                                            CreatedDate 
                                    FROM Plans__r 
                                    WHERE Status__c = 'Active' 
                                    ORDER BY CreatedDate DESC 
                                    LIMIT 1
                                    ) 
                            FROM Account 
                            WHERE Id 
                            IN :scope
                            ]) {

            if (acc.Plan__r.size() > 0) {
                latestActiveIdPlanMap.put(acc.Id, acc.Plan__r[0]);
            }
        }

        // Updating records with the Active latest Plan__c record for each Account record in the scope
        for (Account acc : scope) {
            Plan__c latestPlan = latestActiveIdPlanMap.get(acc.Id);
            if (latestPlan != null) {
                acc.Status__c = latestPlan.Status__c;
                acc.Custodian__c = latestPlan.Custodian__c;
                acc.Fund_List__c = latestPlan.Fund_List__c;
                acc.Service_Option__c = latestPlan.Service_Option__c;
                acc.Safe_Harbor__c = latestPlan.Safe_Harbor__c;
            }
            updatedAccount.add(acc);
        }
        update updatedAccount;
    }

    public void finish(Database.BatchableContext context) {
        // Do any post-processing here
    }
}
