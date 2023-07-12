@isTest
public with sharing class PlanTriggerControllerTest {
    @TestSetup
    static void makeData(){
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 4; i++){
            Account a = new Account(Name = 'Test Account Name ' + i);
            accounts.add(a);
        }
        insert accounts;

        List<Plan__c> plans = new List<Plan__c>();
        for(Integer i = 0; i < 4; i++){
            Plan__c p = new Plan__c(Name = 'Test Plan Name ' + i, Account__c = accounts[i].Id);
            p.Name = 'Plan Name ' + i;
            if(i < 2){
                p.Status__c = 'Inactive';
            } else{
                p.Status__c = 'Active';
            }
            p.Custodian__c = 'Schwab Trust';
            p.Fund_List__c = 'Prudent';
            p.Service_Option__c = 'Partner';
            plans.add(p);
        }
        insert plans;
    } 

    @isTest
    public static void createdPlanUpdateAccountsTest(){
        List<Account> accounts = [SELECT Id,
                                        Name,
                                        Custodian__c,
                                        Fund_List__c,
                                        Service_Option__c,
                                        Safe_Harbor_Formula__c,
                                        Plan_Status__c  
                                FROM Account
                                WHERE Name LIKE 'Test Account Name%'];
        Test.startTest();
        List<Plan__c> plans = new List<Plan__c>();
        for(Account a : accounts){
            Plan__c p = new Plan__c();
            p.Name = 'Test Plan ' + a.Name;
            p.Account__c = a.Id;
            p.Custodian__c = 'Schwab Trust';
            p.Fund_List__c = 'Prudent';
            p.Service_Option__c = 'Partner';
            plans.add(p);
        }
        insert plans;
        Test.stopTest();
        System.assertEquals(4, plans.size(), 'There should be 4 plans created');
    }

    @isTest
    public static void updatePlansUpdateAccountsTest(){
        List<Account> accounts = [SELECT Id,
                                        Name,
                                        Custodian__c,
                                        Fund_List__c,
                                        Service_Option__c,
                                        Safe_Harbor_Formula__c,
                                        Plan_Status__c,
                                        (SELECT Id,
                                                Name,
                                                Status__c
                                        FROM Plans__r)
                                FROM Account
                                WHERE Name LIKE 'Test Account Name%'];
        Test.startTest();
        List<Plan__c> plans = new List<Plan__c>();
        for(Account a : accounts){
            for(Plan__c p : a.Plans__r){
                p.Status__c = 'Active';
                plans.add(p);
            }
        }
        update plans;
        Test.stopTest();
        Account acc = [Select Id, Plan_Status__c FROM Account WHERE Name = 'Test Account Name 0'];
        System.assertEquals(acc.Plan_Status__c, 'Active', 'The plan status should be the same as the account plan status');
    }
}