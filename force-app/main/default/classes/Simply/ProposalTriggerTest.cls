@isTest
public class ProposalTriggerTest {

    @TestSetup
    static void makeData(){

        Account acc  = new Account();
        acc.Name                                    = 'Test Acct';
        acc.BillingPostalCode                       = '12345';
        acc.NumberOfEmployees                       = 5;
        acc.Employer_Identification_Number_EIN__c   = '122456789';
        acc.Business_Unit__c                        = 'Ubiquity';
        acc.Connected_Partner__c                    = 'JPM';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name                    = 'Test Opp';
        opp.Type                        = 'Ancillary Billing Flat Fee';
        opp.StageName               = 'Quote Sent';
        opp.CloseDate               = Date.today();
        opp.AccountId               = acc.Id;
        opp.Product_Type__c           = '401(k)';
        opp.Plan_Type__c             = 'New Plan';
        opp.Service_Option__c           = 'Express(k)';
        opp.LeadSource                  = 'Direct';
        opp.LeadSourceDetail__c         = 'Web Lead Form';
        opp.Method_of_First_Contact__c  = 'Phone';
        insert opp;

        Implementation__c impl   = new Implementation__c();
        impl.Opportunity_Name__c                = opp.Id;
        impl.Advisor_Fees_Paid_from_ESA__c      = 'No';
        impl.Ubiquity_Admin_Fees_Paid_by_ESA__c = 'No';
        impl.Ubiquity_Plan_Effective_Date__c    = Date.today();
        impl.Account__c                         = acc.Id;
        impl.Plan_Type__c                       = 'New Plan';
        impl.Service_Option__c                  = 'Express(k)';
        impl.Participant_Fees_Paid_From_ESA__c  = 'No';
        impl.Implementation_Status__c           = 'In Progress';
        insert impl;

        Plan__c plan = new Plan__c();
        plan.Name = 'test plan';
        insert plan;

        Proposal__c testProp = new Proposal__c();
        testProp.Advisor_CRD__c                              = '55555';
        testProp.Plan_Effective_Date__c                      = date.today();
    testProp.Principal_Opportunity_Stage__c              = 'Presentation';
        testProp.Financial_Professional_Role__c              = 'IAR';
        testProp.Client_Company_Name__c                      = 'Client Company 01';
    testProp.Firm_Name__c                                = 'Advisory Firm 01';
    testProp.Principal_Opportunity_Closed_Lost_Reason__c = 'Unknown';
    testProp.Insurance_Agency_NPN__c                     = 44444;
    testProp.Contact_Phone_Number__c                     = '(555)099-4455';
    testProp.Number_of_Employees__c                      = 5;
    testProp.TPA_Firm_Name__c                            = 'TPA Firm 01';
    testProp.Company_Zip_Postal_Code__c                  = 12345;
    testProp.Company_State__c                            = 'California';
    testProp.Advisor_NPN__c                              = '33333';
        testProp.TPA_EIN__c                                  = '222222222';
        testProp.Company_EIN__c                              = '111111111';
        testProp.Principal_Id__c                             = '000000001';
        testProp.Opportunity__c                              = opp.Id;
        testProp.CreatedDate                                 = Date.valueOf('2022-07-14 00:00:00');
        insert testProp;

        Proposal__c testProp2 = new Proposal__c();
        testProp2.Advisor_CRD__c                              = '55555';
    testProp2.Principal_Opportunity_Stage__c              = 'Presentation';
        testProp2.Financial_Professional_Role__c              = 'IA';
        testProp2.Client_Company_Name__c                      = 'Client Company 02';
    testProp2.Firm_Name__c                                = 'Advisory Firm 02';
    testProp2.Principal_Opportunity_Closed_Lost_Reason__c = 'Unknown';
    testProp2.Insurance_Agency_NPN__c                     = 44444;
    testProp2.Contact_Phone_Number__c                     = '(555)099-4455';
    testProp2.Number_of_Employees__c                      = 5;
    testProp2.TPA_Firm_Name__c                            = 'TPA Firm 02';
    testProp2.Company_Zip_Postal_Code__c                  = 12345;
    testProp2.Company_State__c                            = 'California';
    testProp2.Advisor_NPN__c                              = '33333';
        testProp2.TPA_EIN__c                                  = '222222222';
        testProp2.Company_EIN__c                              = '111111111';
        testProp2.Principal_Id__c                             = '000000002';
        insert testProp2;

        Proposal__c testProp3 = new Proposal__c();
        testProp3.Advisor_CRD__c                              = '55555';
    testProp3.Principal_Opportunity_Stage__c              = 'Committed';
        testProp3.Financial_Professional_Role__c              = 'RR';
        testProp3.Client_Company_Name__c                      = 'Client Company 03';
    testProp3.Firm_Name__c                                = 'Advisory Firm 03';
    testProp3.Principal_Opportunity_Closed_Lost_Reason__c = 'Unknown';
    testProp3.Insurance_Agency_NPN__c                     = 44444;
    testProp3.Contact_Phone_Number__c                     = '(555)099-4455';
    testProp3.Number_of_Employees__c                      = 5;
    testProp3.TPA_Firm_Name__c                            = 'TPA Firm 03';
    testProp3.Company_Zip_Postal_Code__c                  = 12345;
    testProp3.Company_State__c                            = 'California';
    testProp3.Advisor_NPN__c                              = '33333';
        testProp3.TPA_EIN__c                                  = '222222222';
        testProp3.Company_EIN__c                              = '111111111';
        testProp3.Principal_Id__c                             = '000000003';
        insert testProp3;
    }


    @isTest public static void testProposalTriggerNew(){
        List<String> prId = new List<String>{'000000001', '000000002', '000000003'};
        List<Proposal__c> proposalList = [SELECT Id,Client_Company_Name__c,
                                                        Contact_Phone_Number__c,
                                                        Company_State__c,
                                                        Company_EIN__c,
                                                        Company_Zip_Code__c,
                                                        Plan_Effective_Date__c,
                                                        Number_of_Employees__c,
                                                        Advisor_NPN__c,
                                                        Advisor_CRD__c,
                                                        Firm_Name__c,
                                                        TPA_Firm_Name__c,
                                                        TPA_EIN__c,
                                                        Principal_Opportunity_Id__c,
                                                        Principal_Opportunity_Stage__c,
                                                        Principal_Opportunity_Closed_Lost_Reason__c,
                                                        Company_Zip_Postal_Code__c,
                                                        Financial_Professional_Role__c,
                                                        Insurance_Agency_NPN__c,
                                                        Principal_Id__c
                                             FROM Proposal__c
                                             WHERE Principal_Id__c IN :prId];
        for(Proposal__c p: proposalList){
            if(p.Principal_Id__c == '000000001'){
                p.Financial_Professional_Role__c = 'IAR';
                p.Principal_Opportunity_Stage__c = 'Committed';
                p.Manual_Callout__c = true;
            } else if(p.Principal_Id__c == '000000002'){
                p.External_Response__c = '{"errors":[1],"client":{"errors":[1],';
                p.Financial_Professional_Role__c = 'RR';
                p.Principal_Opportunity_Stage__c = 'Committed';
            } else if(p.Principal_Id__c == '000000003'){
                p.Financial_Professional_Role__c = 'RR';
                p.Principal_Opportunity_Stage__c = 'Committed';
            }
        }
        update proposalList;

    Test.setMock(HttpCalloutMock.class, new SimplyCalloutMock());

    }

  @isTest 
    public static void testProposalTriggerFailure(){
        Proposal__c testProp  = new Proposal__c();

        testProp.Advisor_CRD__c                              = '12345';
        testProp.Plan_Effective_Date__c                      = Date.today();
    testProp.Principal_Opportunity_Stage__c              = 'Presentation';
        testProp.Financial_Professional_Role__c              = 'IAR';
        testProp.Client_Company_Name__c                      = 'Client Company 13';
    testProp.Firm_Name__c                                = 'Advisory Firm 00';
    testProp.Principal_Opportunity_Closed_Lost_Reason__c = 'Unknown';
    testProp.Insurance_Agency_NPN__c                     = 44444;
    testProp.Contact_Phone_Number__c                     = '(555)099-4455';
    testProp.Number_of_Employees__c                      = 5;
    testProp.TPA_Firm_Name__c                            = 'TPA Firm 01';
    testProp.Company_Zip_Postal_Code__c                  = 12345;
    testProp.Company_State__c                            = 'California';
    testProp.Advisor_NPN__c                              = '12345';
        testProp.TPA_EIN__c                                  = '222222222';
        testProp.Company_EIN__c                              = '111111111';
        testProp.Principal_Id__c                             = '1234567891';
        insert testProp;

        testProp.Principal_Opportunity_Stage__c              = 'Committed';
        testProp.Financial_Professional_Role__c              = 'IA';
        update testProp;
        Test.setMock(HttpCalloutMock.class, new SimplyCalloutMockFail());
  }
      // @isTest public static void testProposalTriggerUpdate(){
    //     Proposal__c testProp      = new Proposal__c();
    //     Proposal__c testProp2     = new Proposal__c();
    //     Proposal__c testProp3     = new Proposal__c();
    //     Account testAcc        = new Account();
    //     Opportunity testOpp      = new Opportunity();
    //     Implementation__c testImp   = new Implementation__c();
    //     Plan__c testPlan      = new Plan__c();

    //     testAcc.Name            = 'Test Acct';
    //     testAcc.BillingPostalCode = '12345';
    //     testAcc.NumberOfEmployees = 5;
    //     testAcc.Employer_Identification_Number_EIN__c = '122456789';
    //     testAcc.Business_Unit__c  = 'Ubiquity';
    //     testAcc.Connected_Partner__c = 'JPM';
    //     insert testAcc;

    //     testOpp.Name                   = 'Test Opp';
    //     testOpp.Type                       = 'Ancillary Billing Flat Fee';
    //     testOpp.StageName              = 'Quote Sent';
    //     testOpp.CloseDate              = date.today();
    //     testOpp.AccountId              = testAcc.Id;
    //     testOpp.Product_Type__c          = '401(k)';
    //     testOpp.Plan_Type__c            = 'New Plan';
    //     testOpp.Service_Option__c          = 'Express(k)';
    //     testOpp.LeadSource                 = 'Direct';
    //     testOpp.LeadSourceDetail__c        = 'Web Lead Form';
    //     testOpp.Method_of_First_Contact__c = 'Phone';
    //     insert testOpp;

    //     testImp.Opportunity_Name__c = testOpp.Id;
    //     testImp.Advisor_Fees_Paid_from_ESA__c = 'No';
    //     testImp.Ubiquity_Admin_Fees_Paid_by_ESA__c = 'No';
    //     testImp.Ubiquity_Plan_Effective_Date__c = date.today();
    //     testImp.Account__c = testAcc.Id;
    //     testImp.Plan_Type__c = 'New Plan';
    //     testImp.Service_Option__c = 'Express(k)';
    //     testImp.Participant_Fees_Paid_From_ESA__c = 'No';
    //     testImp.Implementation_Status__c = 'In Progress';
    //     insert testImp;

    //     testPlan.Name = 'test plan';
    //     insert testPlan;

    //     testProp.Advisor_CRD__c = '55555';
    //     testProp.Plan_Effective_Date__c = date.today();
  //   testProp.Principal_Opportunity_Stage__c = 'Committed';
    //     testProp.Financial_Professional_Role__c = 'IAR';
    //     testProp.Client_Company_Name__c = 'Client Company 01';
  //   testProp.Firm_Name__c = 'Advisory Firm 01';
  //   testProp.Principal_Opportunity_Closed_Lost_Reason__c = 'Unknown';
  //   testProp.Insurance_Agency_NPN__c = 44444;
  //   testProp.Contact_Phone_Number__c = '(555)099-4455';
  //   testProp.Number_of_Employees__c = 5;
  //   testProp.TPA_Firm_Name__c = 'TPA Firm 01';
  //   testProp.Company_Zip_Postal_Code__c = 12345;
  //   testProp.Company_State__c = 'California';
  //   testProp.Advisor_NPN__c = '33333';
    //     testProp.TPA_EIN__c = '222222222';
    //     testProp.Company_EIN__c = '111111111';
    //     testProp.Principal_Id__c = '1234567891';
    //     testProp.Opportunity__c = testOpp.Id;
    //     testProp.CreatedDate = Date.valueOf('2022-07-14 10:00:00');
    //     testProp.Principal_Opportunity_Id__c = '0065a000013VaSaAAK';
    //     insert testProp;

    //     testProp.External_Response__c = '{"errors":[1],"client":{"errors":[1],';
    //     testProp.Financial_Professional_Role__c = 'RR';
    //     testProp.Principal_Opportunity_Stage__c = 'Committed';
    //     testProp.Manual_Callout__c = true;
    //     update testProp;

    //     testProp2.Advisor_CRD__c = '55555';
    //     testProp2.Plan_Effective_Date__c = date.today();
  //   testProp2.Principal_Opportunity_Stage__c = 'Presentation';
    //     testProp2.Financial_Professional_Role__c = 'RR';
    //     testProp2.Client_Company_Name__c = 'Client Company 01';
  //   testProp2.Firm_Name__c = 'Advisory Firm 01';
  //   testProp2.Principal_Opportunity_Closed_Lost_Reason__c = 'Unknown';
  //   testProp2.Insurance_Agency_NPN__c = 44444;
  //   testProp2.Contact_Phone_Number__c = '(555)099-4455';
  //   testProp2.Number_of_Employees__c = 5;
  //   testProp2.TPA_Firm_Name__c = 'TPA Firm 01';
  //   testProp2.Company_Zip_Postal_Code__c = 12345;
  //   testProp2.Company_State__c = 'California';
  //   testProp2.Advisor_NPN__c = '33333';
    //     testProp2.TPA_EIN__c = '222222222';
    //     testProp2.Company_EIN__c = '111111111';
    //     testProp2.Principal_Id__c = '1234567892';
    //     testProp2.Opportunity__c = testOpp.Id;
    //     testProp2.CreatedDate = Date.valueOf('2022-07-14 10:00:00');
    //     insert testProp2;

    //     testProp2.External_Response__c = '{"errors":[1],"client":{"errors":[1],';
    //     testProp2.Financial_Professional_Role__c = 'RR';
    //     testProp2.Principal_Opportunity_Stage__c = 'Committed';

    //     update testProp2;

    //     Test.setMock(HttpCalloutMock.class, new SimplyCalloutMock());


    //     testProp.Financial_Professional_Role__c = 'IAR';
    //     testProp.Principal_Opportunity_Stage__c = 'Committed';
    //     update testProp;

  //   Test.setMock(HttpCalloutMock.class, new SimplyCalloutMock());
    // }
}
