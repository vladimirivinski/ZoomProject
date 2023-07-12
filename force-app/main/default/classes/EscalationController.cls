global class EscalationController {

    @AuraEnabled
    global static Boolean isEscalated(String accountId) {
        Account acct;
        Id recId = accountId;
        String objectName = recId.getSObjectType().getDescribe().getName();
        System.debug(objectName);
        if(accountId.startsWith('001')){
            List<Account> listAccounts = [SELECT Escalated__c FROM Account WHERE Id = :accountId LIMIT 1];
            acct = listAccounts[0];
        	if(acct.Escalated__c == true){
        		return true;
            }
            else{
                return false;
            }
        }
        else{
            if(objectName.contains('__c')){
                List<sObject> objList = Database.query('SELECT Account__c FROM ' + objectName + ' WHERE Id = :accountId LIMIT 1');
            	sObject objItem = objList[0];
                String objAcct  = (String) objItem.get('Account__c');
                List<Account> listAccounts = [SELECT Escalated__c FROM Account WHERE Id = :objAcct LIMIT 1];
                acct = listAccounts[0];
                if(acct.Escalated__c == true){
                    return true;
                }
                else{
                    return false;
                }
                
            }            
            else{
                List<sObject> objList = Database.query('SELECT AccountId FROM ' + objectName + ' WHERE Id = :accountId LIMIT 1');
            	sObject objItem = objList[0];
                String objAcct  = (String) objItem.get('AccountId');
                List<Account> listAccounts = [SELECT Escalated__c FROM Account WHERE Id = :objAcct LIMIT 1];
                acct = listAccounts[0];
                if(acct.Escalated__c == true){
                    return true;
                }
                else{
                    return false;
                }
            }

        }
    }
    
    @AuraEnabled
    global static List<Escalation__c> getEscalatedRecord(String accountId) {
        Id recId = accountId;
        String objectName = recId.getSObjectType().getDescribe().getName();
        if(objectName.contains('__c')){
            List<sObject> objList = Database.query('SELECT Account__c FROM ' + objectName + ' WHERE Id = :accountId LIMIT 1');
            sObject objItem = objList[0];
            String objAcct  = (String) objItem.get('Account__c');
            List<Escalation__c> activeEsc = [SELECT Id, Escalated_Account__c, Escalation_Contact__c, Escalation_Date__c, Escalation_Type__c, OwnerId, Owner_Full_Name__c, Contact_Full_Name__c
                                             FROM Escalation__c
                                             WHERE Escalated_Account__c = :objAcct 
                                             AND Status__c = 'Escalated' LIMIT 1];
            return activeEsc;
        }
        else if(accountId.startsWith('001')){
            List<Escalation__c> activeEsc = [SELECT Id, Escalated_Account__c, Escalation_Contact__c, Escalation_Date__c, Escalation_Type__c, OwnerId, Owner_Full_Name__c, Contact_Full_Name__c
                                             FROM Escalation__c
                                             WHERE Escalated_Account__c = :accountId 
                                             AND Status__c = 'Escalated' LIMIT 1];
            return activeEsc;
        }
        else{
            List<sObject> objList = Database.query('SELECT AccountId FROM ' + objectName + ' WHERE Id = :accountId LIMIT 1');
            sObject objItem = objList[0];
            String objAcct  = (String) objItem.get('AccountId');
            List<Escalation__c> activeEsc = [SELECT Id, Escalated_Account__c, Escalation_Contact__c, Escalation_Date__c, Escalation_Type__c, OwnerId, Owner_Full_Name__c, Contact_Full_Name__c
                                             FROM Escalation__c
                                             WHERE Escalated_Account__c = :objAcct 
                                             AND Status__c = 'Escalated' LIMIT 1];
            return activeEsc;
    	}
    }
}