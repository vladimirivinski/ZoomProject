@isTest
public class StampDateTest {
    
    @isTest public static void testDateStamp(){
        Account testAcc					   = new Account();
        Opportunity testOpp				   = new Opportunity();
        Implementation__c testImp 		   = new Implementation__c();
        Project_Deliverables__c testDeliv1 = new Project_Deliverables__c();
        Project_Deliverables__c testDeliv2 = new Project_Deliverables__c();
        Project_Deliverables__c testDeliv3 = new Project_Deliverables__c();
        Project_Deliverables__c testDeliv4 = new Project_Deliverables__c();
        Project_Deliverables__c testDeliv5 = new Project_Deliverables__c();
        Project_Task__c testTask1 	 	   = new Project_Task__c();
        Project_Task__c testTask2 	 	   = new Project_Task__c();
        Project_Task__c testTask3 	 	   = new Project_Task__c();
        Project_Task__c testTask4 	 	   = new Project_Task__c();
        Project_Task__c testTask5 	 	   = new Project_Task__c();
        Project_Task__c testTask6 	 	   = new Project_Task__c();
        Work_Breakdown_Structure__c wbs    = new Work_Breakdown_Structure__c();
        Transition__c testTrans			   = new Transition__c();
        Plan__c testPlan				   = new Plan__c();
        Add_On_Products__c testAddOn	   = new Add_On_Products__c();
        
        List<Project_Task__c> completedTasks = new List<Project_Task__c>();
            
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
        insert testImp;
        
        testPlan.Name = 'test plan';        
        insert testPlan;
        
        testTrans.Plan__c = testPlan.Id;
        testTrans.Transition_Type__c = 'Deconversion';
        insert testTrans;
        
        testAddOn.Name = testImp.Name;
        insert testAddOn;
        
        wbs.Name = 'test wbs';
        
        insert wbs;
        
        testDeliv1.Work_Breakdown_Structure__c = wbs.Id;
        testDeliv1.Fields_Stamped_Upon_Completion__c = 'Ubiquity_Plan_Documents_Signed__c';
        testDeliv1.Order_Number__c = 1;
        testDeliv1.Picklist_Completion_Value__c = '';
        testDeliv1.Picklist_Declined_Value__c = '';
        
        insert testDeliv1;
        
        testDeliv2.Work_Breakdown_Structure__c = wbs.Id;
        testDeliv2.Fields_Stamped_Upon_Completion__c = 'Final_Fees_Paid_Accounting__c';
        testDeliv2.Order_Number__c = 1;
        
        insert testDeliv2;
        
        testDeliv3.Work_Breakdown_Structure__c = wbs.Id;
        testDeliv3.Fields_Stamped_Upon_Completion__c = 'GIACT_results__c';
        testDeliv3.Order_Number__c = 1;
        testDeliv3.Picklist_Completion_Value__c = 'Pass';
        testDeliv3.Picklist_Declined_Value__c = 'Fail';
        
        insert testDeliv3;
        
        testDeliv4.Work_Breakdown_Structure__c = wbs.Id;
        testDeliv4.Fields_Stamped_Upon_Completion__c = 'Login_Credentials_Requested__c';
        testDeliv4.Order_Number__c = 1;
        testDeliv4.Picklist_Completion_Value__c = 'Pass';
        testDeliv4.Picklist_Declined_Value__c = 'Fail';
        
        insert testDeliv4;
        
        testDeliv5.Work_Breakdown_Structure__c = wbs.Id;
        testDeliv5.Fields_Stamped_Upon_Completion__c = 'Tested_Login_Credentials__c';
        testDeliv5.Order_Number__c = 1;
        testDeliv5.Picklist_Completion_Value__c = 'Pass';
        testDeliv5.Picklist_Declined_Value__c = 'Fail';
        
        insert testDeliv5;
        
        testTask1.Actual_Start_Date__c      = datetime.now();
        testTask1.Actual_Completion_Date__c = datetime.now();
        testTask1.Status__c                 = 'Completed';
        testTask1.Implementation__c         = testImp.Id;
        testTask1.Project_Deliverable__c    = testDeliv1.Id;
        testTask1.Expected_Completion_Date__c = datetime.now();
        testTask1.Expected_Start_Date__c = datetime.now();
        testTask1.KPI_Milestone__c = 'Sign Plan Documents';
        testTask1.Assigned_To__c = testImp.OwnerId;
        testTask1.Actual_Start_Date__c      = datetime.now();
        testTask1.Actual_Completion_Date__c = datetime.now();
        
        completedTasks.add(testTask1);
        
        testTask2.Actual_Start_Date__c      = datetime.now();
        testTask2.Actual_Completion_Date__c = datetime.now();
        testTask2.Status__c                 = 'Completed';
        testTask2.Transition__c			   = testTrans.Id;
        testTask2.Project_Deliverable__c    = testDeliv2.Id;
        testTask2.Expected_Completion_Date__c = datetime.now();
        testTask2.Expected_Start_Date__c = datetime.now();
        testTask2.KPI_Milestone__c = 'Sign Plan Documents';
        testTask2.Assigned_To__c = testTrans.OwnerId;
        testTask2.Actual_Start_Date__c      = datetime.now();
        testTask2.Actual_Completion_Date__c = datetime.now();
        
        completedTasks.add(testTask2);
        
        testTask3.Actual_Start_Date__c      = datetime.now();
        testTask3.Actual_Completion_Date__c = datetime.now();
        testTask3.Status__c                 = 'Completed';
        testTask3.Implementation__c         = testImp.Id;
        testTask3.Project_Deliverable__c    = testDeliv3.Id;
        testTask3.Expected_Completion_Date__c = datetime.now();
        testTask3.Expected_Start_Date__c = datetime.now();
        testTask3.KPI_Milestone__c = 'Sign Plan Documents';
        testTask3.Assigned_To__c = testImp.OwnerId;
        testTask3.Actual_Start_Date__c      = datetime.now();
        testTask3.Actual_Completion_Date__c = datetime.now();
        
        completedTasks.add(testTask3);
        
        testTask4.Actual_Start_Date__c      = datetime.now();
        testTask4.Actual_Completion_Date__c = datetime.now();
        testTask4.Status__c                 = 'Declined';
		testTask4.Implementation__c         = testImp.Id;
        testTask4.Project_Deliverable__c    = testDeliv3.Id;
        testTask4.Expected_Completion_Date__c = datetime.now();
        testTask4.Expected_Start_Date__c = datetime.now();
        testTask4.KPI_Milestone__c = 'Sign Plan Documents';
        testTask4.Assigned_To__c = testImp.OwnerId;
        testTask4.Actual_Start_Date__c      = datetime.now();
        testTask4.Actual_Completion_Date__c = datetime.now();
        
        completedTasks.add(testTask4);
        
        testTask5.Actual_Start_Date__c        = datetime.now();
        testTask5.Actual_Completion_Date__c   = datetime.now();
        testTask5.Status__c                   = 'Completed';
		testTask5.Opportunity__c              = testOpp.Id;
        testTask5.Project_Deliverable__c      = testDeliv4.Id;
        testTask5.Expected_Completion_Date__c = datetime.now();
        testTask5.Expected_Start_Date__c      = datetime.now();
        testTask5.KPI_Milestone__c            = 'Sign Plan Documents';
        testTask5.Assigned_To__c              = testOpp.OwnerId;
        testTask5.Actual_Start_Date__c        = datetime.now();
        testTask5.Actual_Completion_Date__c   = datetime.now();
        
        completedTasks.add(testTask5);
        
        testTask6.Actual_Start_Date__c        = datetime.now();
        testTask6.Actual_Completion_Date__c   = datetime.now();
        testTask6.Status__c                   = 'Completed';
		testTask6.Add_On_Product__c           = testAddOn.Id;
        testTask6.Project_Deliverable__c      = testDeliv5.Id;
        testTask6.Expected_Completion_Date__c = datetime.now();
        testTask6.Expected_Start_Date__c      = datetime.now();
        testTask6.KPI_Milestone__c            = 'Sign Plan Documents';
        testTask6.Assigned_To__c              = testOpp.OwnerId;
        testTask6.Actual_Start_Date__c        = datetime.now();
        testTask6.Actual_Completion_Date__c   = datetime.now();
        
        completedTasks.add(testTask6);
        
        insert completedTasks;
        }
    }