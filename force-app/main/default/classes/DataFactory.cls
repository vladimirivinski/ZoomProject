@isTest
public with sharing class DataFactory {

    public static Account createAccount(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingPostalCode = '12345';
        acc.NumberOfEmployees = 5;
        acc.Employer_Identification_Number_EIN__c = '122456';
        acc.Business_Unit__c = 'Ubiquity';
        acc.Connected_Partner__c = 'JPM';
        insert acc;
        return acc;
    }

    public static Opportunity createOpportunity(Account acc){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.Type = 'Ancillary Billing Hourly Rate';
        opp.StageName = 'Quote Sent';
        opp.CloseDate = Date.today();
        opp.AccountId = acc.Id; // Assign each opportunity to a different account
        opp.Product_Type__c = '401(k)';
        opp.Plan_Type__c = 'New Plan';
        opp.Service_Option__c = 'Express(k)';
        opp.LeadSource = 'Direct';
        opp.LeadSourceDetail__c = 'Web Lead Form';
        opp.Method_of_First_Contact__c = 'Phone';
        insert opp;
		return opp;
    }

	public static List<Account> createAccounts(Integer numAccounts) {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < numAccounts; i++) {
			Account acc = new Account();
			acc.Name = 'Test' +i+ 'Account' + i;
			acc.BillingPostalCode = '12345' + i;
			acc.NumberOfEmployees = 5 + i;
			acc.Employer_Identification_Number_EIN__c = '122456' + i;
			acc.Business_Unit__c = 'Ubiquity';
			acc.Connected_Partner__c = 'JPM';
			accounts.add(acc);
		}
		insert accounts;
		return accounts;
	}

	public static List<Opportunity> createOpportunities(Integer numOpportunities,  List<Account> accounts) {
		List<Opportunity> opps = new List<Opportunity>();
		for (Integer i = 0; i < numOpportunities; i++) {
			Opportunity opp = new Opportunity();
			opp.Name = 'Test Opp' + i;
			opp.Type = 'Ancillary Billing Hourly Rate';
			opp.StageName = 'Quote Sent';
			opp.CloseDate = Date.today();
			opp.AccountId = accounts[i].Id; // Assign each opportunity to a different account
			opp.Product_Type__c = '401(k)';
			opp.Plan_Type__c = 'New Plan';
			opp.Service_Option__c = 'Express(k)';
			opp.LeadSource = 'Direct';
			opp.LeadSourceDetail__c = 'Web Lead Form';
			opp.Method_of_First_Contact__c = 'Phone';
			opps.add(opp);
		}
		insert opps;
		return opps; // Return the list of created opportunities
	}

	public static List<Proposal__c> createProposals(Integer numProposals, Opportunity opportunity) {
		List<Proposal__c> proposals = new List<Proposal__c>();
		for (Integer i = 0; i < numProposals; i++) {
			Proposal__c testProp = new Proposal__c();
			testProp.Advisor_CRD__c = '55555';
			testProp.Plan_Effective_Date__c = Date.today();
			testProp.Client_Company_Name__c = 'Client Company 0' + i;
			testProp.Firm_Name__c = 'Advisory Firm 0' + i;
			testProp.Principal_Opportunity_Closed_Lost_Reason__c = 'Unknown';
			testProp.Insurance_Agency_NPN__c = 4444 + i;
			testProp.Number_of_Employees__c = 5 + i;
			testProp.Contact_Phone_Number__c = '(555)099-4455';
			testProp.TPA_Firm_Name__c = 'TPA Firm 0' + i;
			testProp.Company_Zip_Postal_Code__c = 12345;
			testProp.Company_State__c = 'California';
			testProp.Advisor_NPN__c = '3333' + i;
			testProp.TPA_EIN__c = '123456' + i;
			testProp.Company_EIN__c = '123456' + i;
			testProp.Opportunity__c = opportunity.Id; // Assign each proposal to a different opportunity
			testProp.CreatedDate = Date.valueOf('2022-07-14 00:00:00');
			if (i <= 100) {
				testProp.Principal_Opportunity_Stage__c = 'Presentation';
				testProp.Financial_Professional_Role__c = 'IAR';
				testProp.Principal_Id__c = '000' + i;
			} else if (i > 100 && i < 150) {
				testProp.Principal_Opportunity_Stage__c = 'Presentation';
				testProp.Financial_Professional_Role__c = 'IA';
				testProp.Principal_Id__c = '100' + i;
			} else if (i >= 150) {
				testProp.Principal_Opportunity_Stage__c = 'Committed';
				testProp.Financial_Professional_Role__c = 'RR';
				testProp.Principal_Id__c = '200' + i;
			}
			proposals.add(testProp);
		}
		insert proposals;
		return proposals; // Return the list of created proposals
	}
}
