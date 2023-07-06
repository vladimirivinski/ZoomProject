public with sharing class TestAccountsCreation {

    public static List<Account> createListAccount(Integer size) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < size; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account ' + i;
            acc.Website = 'www.testaccount' + i + '.com';
            accounts.add(acc);
            
        }
        return accounts;
    }

    public static void deleteAccounts(String name) {
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name LIKE :name + '%'];
        delete accounts;
    }
}