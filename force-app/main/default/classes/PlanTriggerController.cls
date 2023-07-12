public with sharing class PlanTriggerController {

    public static void createdPlanUpdateAccounts(List<Plan__c> plans){
        Set<Id> accountIds = new Set<Id>();
        for (Plan__c plan : plans){
            accountIds.add(plan.Account__c);
        }

        List<Account> accounts = [SELECT Id,
                                        Custodian__c,
                                        Fund_List__c,
                                        Service_Option__c,
                                        Safe_Harbor_Formula__c,
                                        Plan_Status__c
                                FROM Account
                                WHERE Id IN :accountIds
                                WITH SECURITY_ENFORCED];

        for (Account account : accounts) {
            for (Plan__c plan : plans) {
                if (plan.Account__c == account.Id) {
                    account.Custodian__c            = plan.Custodian__c;
                    account.Fund_List__c            = plan.Fund_List__c;
                    account.Service_Option__c       = plan.Service_Option__c;
                    account.Safe_Harbor_Formula__c  = plan.Safe_Harbor__c;
                    account.Plan_Status__c          = plan.Status__c;
                }
            }
        }
        try {
            Database.update(accounts);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }


    public static void afterUpdatePlan(Map<Id, Plan__c> plans){
        List<Account> accountsToUpdate = new List<Account>();

        Set<Id> accountIds = new Set<Id>();
        for (Plan__c plan : plans.values()) {
            accountIds.add(plan.Account__c);
        }

        List<Plan__c> latestPlans = getLatestPlans(accountIds);
        for(Plan__c plan: plans.values()){
            Id accId = plan.Account__c;
            for(Plan__c latestPlan: latestPlans){
                if(plan.Id == latestPlan.Id && accId != null){
                    Account acc = new Account(Id = accId);
                    acc.Custodian__c           = latestPlan.Custodian__c;
                    acc.Fund_List__c           = latestPlan.Fund_List__c;
                    acc.Service_Option__c      = latestPlan.Service_Option__c;
                    acc.Safe_Harbor_Formula__c = latestPlan.Safe_Harbor__c;
                    acc.Plan_Status__c         = latestPlan.Status__c;
                    accountsToUpdate.add(acc);
                }
            }
        }
        if (!accountsToUpdate.isEmpty()) {
            try {
                Database.update(accountsToUpdate);
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    public static List<Plan__c> getLatestPlans(Set<Id> accountIds){

        List<Plan__c> resultAccountsPlan = new List<Plan__c>();

        for(Account acc: [SELECT 
                                Id, 
                                Custodian__c, 
                                Fund_List__c, 
                                Service_Option__c, 
                                Safe_Harbor_Formula__c, 
                                Plan_Status__c, 
                                CreatedDate,
                                    (SELECT 
                                            Id, 
                                            Status__c, 
                                            Custodian__c, 
                                            Fund_List__c, 
                                            Service_Option__c, Safe_Harbor__c, CreatedDate 
                                    FROM Plans__r
                                    ORDER BY CreatedDate DESC) 
                        FROM Account 
                        WHERE Id IN :accountIds 
                        WITH SECURITY_ENFORCED]){

            List<Plan__c> activePlans = new List<Plan__c>();
            List<Plan__c> otherPlans = new List<Plan__c>();
            Plan__c latestPlan = null;
            
            for(Plan__c plan: acc.Plans__r){
                if(plan.Status__c == 'Active'){
                    activePlans.add(plan);
                } else {
                    otherPlans.add(plan);
                } 
            }

            if(!activePlans.isEmpty()){
                for(Plan__c activePlan: activePlans){
                    if(latestPlan == null || latestPlan.CreatedDate < activePlan.CreatedDate){
                        latestPlan = activePlan;
                        resultAccountsPlan.add(latestPlan);
                    }
                }
            } else if(activePlans.isEmpty()){
                for(Plan__c otherPlan: otherPlans){
                    if(latestPlan == null || latestPlan.CreatedDate < otherPlan.CreatedDate){
                        latestPlan = otherPlan;
                        resultAccountsPlan.add(latestPlan);
                    }
                }
            }
        }
        return resultAccountsPlan;
    }
}