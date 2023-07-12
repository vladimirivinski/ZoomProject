@isTest
public class StampImpTest {
    
    @isTest public static void testDateStamp(){
        Account testAcc					  = new Account();
        Opportunity testOpp				  = new Opportunity();
        Implementation__c testImp 		  = new Implementation__c();
        Project_Deliverables__c testDeliv = new Project_Deliverables__c();
        Project_Task__c testTask 	 	  = new Project_Task__c();
        Work_Breakdown_Structure__c wbs   = new Work_Breakdown_Structure__c();
            
        testAcc.Name      		  = 'Test Acct';
        testAcc.BillingPostalCode = '12345';
        testAcc.NumberOfEmployees = 5;
        testAcc.Employer_Identification_Number_EIN__c = '122456789';
        testAcc.Business_Unit__c  = 'Ubiquity';
        testAcc.Connected_Partner__c = 'JPM';
        
        insert testAcc;
        
        testOpp.Name      			= 'Test Opp';
        testOpp.Type                = 'Ancillary Billing Flat Fee';
        testOpp.StageName 			= 'Quote Sent';
        testOpp.CloseDate 			= date.today();
        testOpp.AccountId 			= testAcc.Id;
        testOpp.Product_Type__c 	= '401(k)';
        testOpp.Plan_Type__c 		= 'New Plan';
        testOpp.Service_Option__c   = 'Express(k)';
        testOpp.LeadSource          = 'Direct';
        testOpp.LeadSourceDetail__c = 'Web Lead Form';
        testOpp.Method_of_First_Contact__c = 'Phone';
        
        insert testOpp;
            
        testImp.Opportunity_Name__c = testOpp.Id;
        testImp.Advisor_Fees_Paid_from_ESA__c = 'No';
        testImp.Ubiquity_Admin_Fees_Paid_by_ESA__c = 'No';
        testImp.Ubiquity_Plan_Effective_Date__c = date.today();
        testImp.Account__c = testAcc.Id;
        testImp.Plan_Type__c = 'New Plan';
        testImp.Service_Option__c = 'Express(k)';
        testImp.Participant_Fees_Paid_From_ESA__c = 'No';
        
        testTask.Actual_Start_Date__c      = datetime.now();
        testTask.Actual_Completion_Date__c = datetime.now();
        testTask.Status__c                 = 'Ready';
    	
        insert testImp;
        
        wbs.Name = 'test wbs';
        
        insert wbs;
        
        testDeliv.Work_Breakdown_Structure__c = wbs.Id;
        testDeliv.Fields_Stamped_Upon_Completion__c = 'Ubiquity_Plan_Documents_Signed__c';
        testDeliv.Order_Number__c = 1;
        
        insert testDeliv;
        
        testTask.Actual_Start_Date__c      = datetime.now();
        testTask.Actual_Completion_Date__c = datetime.now();
        testTask.Status__c                 = 'Completed';
        testTask.Implementation__c         = testImp.Id;
        testTask.Project_Deliverable__c    = testDeliv.Id;
        testTask.Expected_Completion_Date__c = datetime.now();
        testTask.Expected_Start_Date__c = datetime.now();
        testTask.KPI_Milestone__c = 'Sign Plan Documents';
        testTask.Assigned_To__c = testImp.OwnerId;
        
        insert testTask;
        }
    }