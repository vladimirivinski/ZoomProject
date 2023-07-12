/*
	CloneListTest.cls
	
	Last Modified April 19 2011
	
	Test Class for CloneListController.cls, CloneListUtil.cls and ChildRelationship.cls
*/

@isTest
public with sharing class CloneListTest {	
	static testmethod void testCloneListControllerOne() {
		Account testAccountOne = new Account();
		testAccountOne.Name = 'Test Account 1';
		insert testAccountOne;
		Account testAccountTwo = new Account();
		testAccountTwo.Name = 'Test Account 2';
		insert testAccountTwo;
		Contact testContactOne = new Contact();
		testContactOne.LastName = 'Test Contact 1';
		testContactOne.AccountId = testAccountOne.Id;
		insert testContactOne;
		Contact testContactTwo = new Contact();
		testContactTwo.LastName = 'Test Contact 2';
		testContactTwo.AccountId = testAccountOne.Id;
		insert testContactTwo;
		Test.setCurrentPage(Page.CloneListPage);
		Test.startTest();
		CloneListController controller = new CloneListController();
		controller.sourceId = testAccountOne.Id;
		controller.getChildRecords();
		controller.destinationId = testAccountTwo.Id;
		controller.copyChildRecords();
		System.assertEquals(0, [select count() from Contact where AccountId =: testAccountTwo.Id]);
		Test.stopTest();
	}

	static testmethod void testCloneListControllerTwo() {
		Account testAccountOne = new Account();
		testAccountOne.Name = 'Test Account 1';
		insert testAccountOne;
		Account testAccountTwo = new Account();
		testAccountTwo.Name = 'Test Account 2';
		insert testAccountTwo;
		Contact testContactOne = new Contact();
		testContactOne.LastName = 'Test Contact 1';
		testContactOne.AccountId = testAccountOne.Id;
		insert testContactOne;
		Contact testContactTwo = new Contact();
		testContactTwo.LastName = 'Test Contact 2';
		testContactTwo.AccountId = testAccountOne.Id;
		insert testContactTwo;
		Test.setCurrentPage(Page.CloneListPage);
		Test.startTest();
		System.currentPageReference().getParameters().put('sourceId', testAccountOne.Id);
		CloneListController controller = new CloneListController();
		controller.cloneParent = false;
		for(ChildRelationship cr : controller.childRecords) {
			if(cr.getRecordAmount() > 0) {
				cr.setSelected(true);
			}
		}
		controller.destinationId = testAccountTwo.Id;
		controller.copyChildRecords();
		System.assertEquals(0, [select count() from Contact where AccountId =: testAccountTwo.Id]);
		Test.stopTest();
	}
	
	static testmethod void testCloneListControllerThree() {
		Account testAccountOne = new Account();
		testAccountOne.Name = 'Test Account 1';
		insert testAccountOne;
		Account testAccountTwo = new Account();
		testAccountTwo.Name = 'Test Account 2';
		insert testAccountTwo;
		Contact testContactOne = new Contact();
		testContactOne.LastName = 'Test Contact 1';
		testContactOne.AccountId = testAccountOne.Id;
		insert testContactOne;
		Contact testContactTwo = new Contact();
		testContactTwo.LastName = 'Test Contact 2';
		testContactTwo.AccountId = testAccountOne.Id;
		insert testContactTwo;
		Test.setCurrentPage(Page.CloneListPage);
		System.currentPageReference().getParameters().put('destinationId', testAccountTwo.Id);
		Test.startTest();
		CloneListController controller = new CloneListController();
		controller.sourceId = testAccountOne.Id;
		controller.getChildRecords();
		for(ChildRelationship cr : controller.childRecords) {
			if(cr.getRecordAmount() > 0) {
				cr.setSelected(true);
			}
		}
		controller.copyChildRecords();
		System.assertEquals(0, [select count() from Contact where AccountId =: testAccountTwo.Id]);
		Test.stopTest();
	}
	
	static testmethod void testCloneListControllerFour() {
		Account testAccountOne = new Account();
		testAccountOne.Name = 'Test Account 1';
		insert testAccountOne;
		Account testAccountTwo = new Account();
		testAccountTwo.Name = 'Test Account 2';
		insert testAccountTwo;
		Contact testContactOne = new Contact();
		testContactOne.LastName = 'Test Contact 1';
		testContactOne.AccountId = testAccountOne.Id;
		insert testContactOne;
		Contact testContactTwo = new Contact();
		testContactTwo.LastName = 'Test Contact 2';
		testContactTwo.AccountId = testAccountOne.Id;
		insert testContactTwo;
		Test.setCurrentPage(Page.CloneListPage);
		Test.startTest();
		CloneListController controller = new CloneListController();
		controller.sourceId = testAccountOne.Id;
		controller.getChildRecords();
		for(ChildRelationship cr : controller.childRecords) {
			if(cr.getRecordAmount() > 0) {
				cr.setSelected(true);
			}
		}
		controller.destinationId = testContactOne.Id;
		controller.copyChildRecords();
		System.assertEquals(0, [select count() from Contact where AccountId =: testAccountTwo.Id]);
		controller.sourceId = '1233';
		controller.getChildRecords();
		controller.destinationId = '412';
		controller.copyChildRecords();
		System.assertEquals(0, [select count() from Contact where AccountId =: testAccountTwo.Id]);
		Test.stopTest();		
	}
	
	static testmethod void testCloneListControllerFive() {
		Account testAccountOne = new Account();
		testAccountOne.Name = 'Test Account 1';
		insert testAccountOne;
		Contact testContactOne = new Contact();
		testContactOne.LastName = 'Test Contact 1';
		testContactOne.AccountId = testAccountOne.Id;
		insert testContactOne;
		Contact testContactTwo = new Contact();
		testContactTwo.LastName = 'Test Contact 2';
		testContactTwo.AccountId = testAccountOne.Id;
		insert testContactTwo;
		Test.setCurrentPage(Page.CloneListPage);
		Test.startTest();
		System.currentPageReference().getParameters().put('sourceId', testAccountOne.Id);
		CloneListController controller = new CloneListController();
		for(ChildRelationship cr : controller.childRecords) {
			if(cr.getRecordAmount() > 0) {
				cr.setSelected(true);
			}
		}
		controller.cloneParent = true;
		controller.setCloneParent();
		controller.copyChildRecords();
		System.assertEquals(0, [select count() from Contact where AccountId =: controller.destinationId]);
		Test.stopTest();		
	}		
}