@isTest
public class EscalationControllerTest {
    
	static testMethod void testEscalation() {
        Account acct = new Account(Name='Test');
        acct.Escalated__c = true;
        acct.NumberOfEmployees = 5;
        insert acct;

        Contact cont = new Contact(LastName='TestCont');
        cont.AccountId = acct.Id;
        insert cont;
        
        Opportunity opp = new Opportunity(Name='Test');
        opp.AccountId = acct.Id;
        opp.StageName = 'Requested';
        opp.Ancillary_Billing_Category__c = 'ADP/ACP Testing';
        opp.CloseDate = Date.today();
        opp.Description = 'test';
        opp.RecordTypeId = '0121G000000g1YIQAY';
        insert opp;
        
        Implementation__c imp = new Implementation__c(Name='Test');
        imp.Account__c = acct.Id;
        imp.Opportunity_Name__c = opp.Id;
        insert imp;
        
        String acctId = acct.Id;
        String recId  = cont.Id;
        String custId = imp.Id;
        
        Account acct2 = new Account(Name='Test');
        acct2.Escalated__c = false;
        insert acct2;

        Contact cont2 = new Contact(LastName='TestCont');
        cont2.AccountId = acct2.Id;
        insert cont2;
        
        Opportunity opp2 = new Opportunity(Name='Test');
        opp2.AccountId = acct.Id;
        opp2.StageName = 'Requested';
        opp2.Ancillary_Billing_Category__c = 'ADP/ACP Testing';
        opp2.CloseDate = Date.today();
        opp2.Description = 'test';
        opp2.RecordTypeId = '0121G000000g1YIQAY';
        insert opp2;
        
        Implementation__c imp2 = new Implementation__c(Name='Test');
        imp2.Account__c = acct2.Id;
        imp2.Opportunity_Name__c = opp2.Id;
        insert imp2;
        
        String acctId2 = acct2.Id;
        String recId2  = cont2.Id;
        String custId2 = imp2.Id;

        Escalation__c newEsc = new Escalation__c();
        newEsc.Escalated_Account__c = acct.Id;
        newEsc.Escalation_Contact__c = cont.Id;
        newEsc.Status__c = 'Escalated';
        insert newEsc;
        
               
        System.assertEquals(EscalationController.isEscalated(acctId), True);
        System.assertEquals(EscalationController.isEscalated(recId), True);
        System.assertEquals(EscalationController.isEscalated(custId), True);
        System.assertEquals(EscalationController.isEscalated(acctId2), False);
        System.assertEquals(EscalationController.isEscalated(recId2), False);
        System.assertEquals(EscalationController.isEscalated(custId2), False);
        
        List<Escalation__c> result = EscalationController.getEscalatedRecord(acctId);
        List<Escalation__c> result2 = EscalationController.getEscalatedRecord(recId);
        List<Escalation__c> result3 = EscalationController.getEscalatedRecord(custId);
        system.assertEquals(1, result.size());
        system.assertEquals(1, result2.size());        
        system.assertEquals(1, result3.size()); 

    }
}