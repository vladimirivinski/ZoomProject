/*
	CloneListController.cls
	
	Last Modified April 19 2011
	
	Controller for CloneListPage.page
*/
public with sharing class CloneListController {
	
	public String sourceId {get; set;}//Id of record with child records
	public String destinationId {get; set;}//Id of record to copy child records to
	public List<ChildRelationship> childRecords {get; set;}//Custom Apex class list of Child Records view
	
	public Boolean blockSource {get; set;}//Block Source if already loaded
	public Boolean blockDestination {get; set;}//Source Id boolean validation
	public Boolean blockDestinationButton {get; set;}
	public Boolean cloneParent {get; set;}//Clone Parent Record too
	
	private String objectName;//Object name of Source and Destination Id
	
	/*
		Constructor for CloneListController
		
		@params - none
		
		See if there is a sid(Source Id) and/or did(Destination Id) in the URL
		Include Help Text message on CloneListPage.page
	*/
	public CloneListController() {
		blockDestination = true;
		blockDestinationButton = true;
		cloneParent = false;
		blockSource = false;
		//Ability to include the Source Id in URL param
		if(ApexPages.currentPage().getParameters().get('sourceId') != null) {
			sourceId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('sourceId'));
			getChildRecords();
			cloneParent = true;
			blockSource = true;
			setCloneParent();
		}
		
		//Ability to include the Destination Id in URL param
		if(ApexPages.currentPage().getParameters().get('destinationId') != null) {
			destinationId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('destinationId'));
		}
		
		//Help text on the Visualforce Page. Possible Instructional Text
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
			System.Label.CLONE_LIST_CONTROLLER_CONSTRUCTOR_TITLE, 
			System.Label.CLONE_LIST_CONTROLLER_CONSTRUCTOR_MESSAGE)); 
	}
	
	
	/*
		setCloneParent Method
		
		@params - none
		
		Action Support on Visualforce page which verifies if the source record is to be cloned too
	*/
	public PageReference setCloneParent() {
		if(childRecords != null) {
			if(cloneParent) {
				blockDestination = true;//Disable text field is true
			} else {
				blockDestination = false;//Enable text field if destination id is required
			}
			blockDestinationButton = false;//Disable button is false
		} 
		return null;
	}

	/*
		getChildRecords Method
		
		@params - none
		
		Command Button on Visualforce page or called from constructor which verifies Source Id and outputs
		possible clone related list options
	*/	
	public void getChildRecords() {
		//sObject name associated with Id
		objectName = CloneListUtil.getObjectNameBasedOnPrefix(String.escapeSingleQuotes(sourceId));
		if(objectName != '') {
			try {
				childRecords = CloneListUtil.getChildRecordNames(objectName, String.escapeSingleQuotes(sourceId));
				if(childRecords == null) {//If Source Id's object has no related lists on it i.e. new custom object
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
						System.Label.CLONE_LIST_CONTROLLER_NO_CHILD_OBJECTS_ERROR_TITLE, 
						System.Label.CLONE_LIST_CONTROLLER_NO_CHILD_OBJECTS_ERROR_MESSAGE + objectName));
				} else {
					Integer totalChildAmount = 0;
					for(ChildRelationship childAmountCheck : childRecords) {
						totalChildAmount += childAmountCheck.getRecordAmount();
					}
					if(totalChildAmount == 0) {//If all of the related lists have no records to clone
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
							System.Label.CLONE_LIST_CONTROLLER_NO_CHILD_RECORDS_TITLE, 
							System.Label.CLONE_LIST_CONTROLLER_NO_CHILD_RECORDS_MESSAGE));
					} else {
						setCloneParent();
					}
				}
			} catch(Exception e) {
				ApexPages.addMessages(e);
			}
		} else {//If source Id is not a valid Id on this org
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
				System.Label.CLONE_LIST_CONTROLLER_NOT_AN_ID_ERROR_TITLE, 
				System.Label.CLONE_LIST_CONTROLLER_NOT_AN_ID_ERROR_MESSAGE_1 + sourceId + 
				System.Label.CLONE_LIST_CONTROLLER_NOT_AN_ID_ERROR_MESSAGE_2));
				childRecords = null;
		}
	}
	
	/*
		copyChildRecords Method
		
		@params - none
		
		Command Button on Visualforce page which, after the source Id is verified, the process of cloning child records
		from the source record to the destination record is initiated
	*/		
	public PageReference copyChildRecords() {
		if(CloneListUtil.verifyChildObjectSelected(childRecords)) {//Verify if any of the child objects have been selected
			Boolean parentError = false;
			if(cloneParent) {
				Database.SaveResult saveParentResult = CloneListUtil.createCloneParentRecord(String.escapeSingleQuotes(sourceId));//clone parent record
				if(saveParentResult.isSuccess()) {//If successful show Id, if not show error
					destinationId = saveParentResult.getId();//Newly created destination Id
				} else {
					parentError = true;
					for(Database.Error dbError : saveParentResult.getErrors()) {//If there were errors, show to Visualforce page
						addErrorToPage(dbError.getStatusCode().name(), dbError.getMessage());
					}
				}
			}
			//Verify that the source sObject type is the same as the destination sObject type
			if(!parentError) {
				String destinationName = CloneListUtil.getObjectNameBasedOnPrefix(String.escapeSingleQuotes(destinationId));
				if(destinationName != '') {
					if(objectName == destinationName) {
						try {
							List<Database.Error> dbErrors = CloneListUtil.createCloneChildRecords(String.escapeSingleQuotes(sourceId), String.escapeSingleQuotes(destinationId), childRecords);
							if(dbErrors.isEmpty()) {//Verify if there were no errors in the copy functionality
								return new PageReference('/'+String.escapeSingleQuotes(destinationId));
							} else {
								for(Database.Error dbError : dbErrors) {//If there were errors, show to Visualforce page
									addErrorToPage(dbError.getStatusCode().name(), dbError.getMessage());
								}
							}
						} catch(Exception e) {
							ApexPages.addMessages(e);
						}
					} else {//Show to Visualforce page if the Source and Destination are not the same sObject
						addErrorToPage(System.Label.CLONE_LIST_CONTROLLER_OBJECT_MISMATCH_ERROR_TITLE, 
							System.Label.CLONE_LIST_CONTROLLER_OBJECT_MISMATCH_ERROR_MESSAGE_1 + objectName + 
							System.Label.CLONE_LIST_CONTROLLER_OBJECT_MISMATCH_ERROR_MESSAGE_2 + destinationName + 
							System.Label.CLONE_LIST_CONTROLLER_OBJECT_MISMATCH_ERROR_MESSAGE_3);
					}
				} else {//Show to Visualforce page if the Destination Id is not a valid Id
					addErrorToPage(System.Label.CLONE_LIST_CONTROLLER_NOT_AN_ID_ERROR_TITLE, 
						System.Label.CLONE_LIST_CONTROLLER_NOT_AN_ID_ERROR_MESSAGE_DESTINATION_1 + destinationId + 
						System.Label.CLONE_LIST_CONTROLLER_NOT_AN_ID_ERROR_MESSAGE_2);
				}
			} else {//Show to Visualforce page if user has not selected any child records to copy
				addErrorToPage(System.Label.CLONE_LIST_CONTROLLER_NOT_SELECTED_ERROR_TITLE, 
					System.Label.CLONE_LIST_CONTROLLER_NOT_SELECTED_ERROR_MESSAGE);
			}
		} else {//Show to Visualforce page if parent record did not copy
			addErrorToPage(System.Label.CLONE_LIST_CONTROLLER_PARENT_CLONE_RECORD_ERROR_TITLE, 
				System.Label.CLONE_LIST_CONTROLLER_PARENT_CLONE_RECORD_ERROR_MESSAGE);
		}
		return null;
	}

	/*
		addErrorToPage Method
		
		@params - String, String
		
		Add Error Messages to Visualforce page
	*/		
	public void addErrorToPage(String title, String message) {
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, title, message));
	}
}