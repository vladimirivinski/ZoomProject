/*
	CloneListController.cls
	
	Last Modified April 19 2011
	
	Utility Class for CloneListController
*/
public with sharing class CloneListUtil {
	
	public static Map<String, Schema.SobjectType> schemaMap = Schema.getGlobalDescribe();//Get sObject name from Id

	/*
		verifyChildObjectSelected Static Method
		
		@params - List<ChildRelationship>
		
		Verify that the user has selected any Child Objects to copy from the Source to
		Destination
	*/	
	public static Boolean verifyChildObjectSelected(List<ChildRelationship> childObjects) {
		if(childObjects != null) {
			for(ChildRelationship cr : childObjects) {
				if(cr.getSelected()) {
					return true;
				}
			}
		}
		return false;
	}


	/*
		verifyChildObjectSelected Static Method
		
		@params - String
		
		Get the object name of the source Id based on its prefix(first three characters of sObject)
	*/	
	public static String getObjectNameBasedOnPrefix(String id) {
		String objectName = '';
		if(id.length() == 15 || id.length() == 18) {//Stanard Id size of 15 or 18
			for(Schema.SobjectType schema : schemaMap.values()) {//Loop through Metadata to get object name via prefix
				if(schema.getDescribe().getKeyPrefix() != null && id.startsWith(schema.getDescribe().getKeyPrefix())) {
					objectName = schema.getDescribe().getName();
				}
			}
		}
		return objectName;
	}

	/*
		getChildRecordNames Static Method
		
		@params - String, String
		
		Get Child Relationship sObjects from sObject, verify records can be queried, accessed, created and updated
		by the current User or the org in general, get a count of each related list and output ChildRelationship
		records to CloneListController.cls
	*/		
	public static List<ChildRelationship> getChildRecordNames(String objectName, String sourceId) {
		List<Schema.ChildRelationship> describeObjectChildren = 
			schemaMap.get(objectName).getDescribe().getChildRelationships();
		
		if(describeObjectChildren == null || describeObjectChildren.size() == 0) {//Verify child relationships exist
			return null;
		}
		
		List<ChildRelationship> childRecords = new List<ChildRelationship>();
		for(Schema.ChildRelationship childDescribe : describeObjectChildren) {
			Schema.DescribeSObjectResult childObject = childDescribe.getChildSObject().getDescribe();
			if(childObject.isQueryable() && childObject.isAccessible() && childObject.isCreateable() && childObject.isUpdateable()) {
				ChildRelationship childRecord = new ChildRelationship();
				childRecord.setMasterDetail(childDescribe.isCascadeDelete());//Master Detail
				childRecord.setRelationshipName(childDescribe.getRelationshipName());//API Name
				childRecord.setObjectName(childObject.getName());//sObject Api name
				childRecord.setFieldName(childDescribe.getField().getDescribe().getName());//API Name
				childRecord.setSelected(false);
				childRecords.add(childRecord);
			}
		}
		//Queries do exist within loop, amount of queries is based on n amount Child records
		for(ChildRelationship child : childRecords) {//Loop through and get counts of child records on parent record
			String query = 'select count() from ' + child.getObjectName() + ' where ' + child.getFieldName() + '= \'' + sourceId + '\'';
			Integer countValue = Database.countQuery(query);
			child.setRecordAmount(countValue);
		}
		
		return childRecords;
	}
	
	/*
		createCloneParentRecord Static Method
		
		@params - String
		
		Set Savepoint before DML if rollback is needed, create SOQL for parent sObject, query, clone, 
		and insert new record. If there are errors present in any of the transactions, rollback
		the whole process and alert user of DML errors
	*/	
	public static Database.SaveResult createCloneParentRecord(String sourceId) {
		Savepoint sp = Database.setSavepoint();//For possible rollback if there are errors present in DML
		String objectName = CloneListUtil.getObjectNameBasedOnPrefix(sourceId);//Get object name
		String query = CloneListUtil.generateSelectAllQuery(objectName, 'Id', sourceId);//Generate query
		List<SObject> currentParentRecord = Database.query(query);//Query child records on child sObject
		List<SObject> newParentRecord = currentParentRecord.deepClone(false);//Clone queried records
		Database.SaveResult[] newData = Database.Insert(newParentRecord, true);//Insert newly cloned records
		if(!newData.get(0).isSuccess()) {
			Database.rollback(sp);//Rollback if errors present
		}
		return newData.get(0);
	}
	
	
	/*
		createCloneChildRecords Static Method
		
		@params - String, String, List<ChildRelationship>
		
		Set Savepoint before DML if rollback is needed, create SOQL for child sObjects, query, clone, 
		and insert new records. If there are errors present in any of the transactions, rollback
		the whole process and alert user of DML errors
	*/	
	public static List<Database.Error> createCloneChildRecords(String sourceId, String destinationId, List<ChildRelationship> childRecords) {
		Savepoint sp = Database.setSavepoint();//For possible rollback if there are errors present in DML
		List<Database.SaveResult> databaseResults = new List<Database.SaveResult>();
		for(ChildRelationship child : childRecords) {//There are queries and DML in the loop, n amount based on criteria below
			if(child.getSelected() && child.getRecordAmount() > 0) {//Verify child objects are selected
				String query = CloneListUtil.generateSelectAllQuery(child.getObjectName(), child.getFieldName(), sourceId);//Generate query
				List<SObject> currentRecords = Database.query(query);//Query child records on child sObject
				List<SObject> newRecords = currentRecords.deepClone(false);//Clone queried records
				for(SObject s : newRecords) {
					s.put(child.getFieldName(), destinationId);//Set new parent Id
				}
				Database.SaveResult[] newData = Database.Insert(newRecords, true);//Insert newly cloned records
				databaseResults.addAll(newData);//Gather all results
			}
		}
		List<Database.Error> errorsFromSave = new List<Database.Error>();
		for(Database.SaveResult dbResult : databaseResults) {
			if(!dbResult.isSuccess()) {//Validate if there were any errors on the insert database process
				errorsFromSave.addAll(dbResult.getErrors());
			}
		}
		if(!errorsFromSave.isEmpty()) {//If there were errors, rollback entire process
			Database.rollback(sp);
		}
		return errorsFromSave;
	}

	/*
		generateSelectAllQuery Static Method
		
		@params - String, String, String
		
		Generate query based for child sObject via the source Id. Verify that fields are accessible, 
		createable, not unique, not auto number, not calculated, not formula
	*/	
	public static String generateSelectAllQuery(String objectName, String fieldName, String sourceId) {
		String query = 'select Id';
		for(Schema.SObjectField field : schemaMap.get(objectName).getDescribe().fields.getMap().values()) {
			if(field.getDescribe().isAccessible() && field.getDescribe().isCreateable() && !field.getDescribe().isUnique() &&
				!field.getDescribe().isAutoNumber() && !field.getDescribe().isCalculated() && !field.getDescribe().isDefaultedOnCreate()) {
				query += ',' + field.getDescribe().getName();//Add field names to query
			}
		}
		
		/*Special cases*/
		//Unit Price on OpportunityLineItem requires a manual update but does 
		//not agree with the field criteria above so its a special case
		if(objectName.contains('OpportunityLineItem')) {
			query += ',UnitPrice';
		}
		/*Special cases*/
		query += ' from ' + objectName + ' where ' + fieldName + '= \'' + sourceId + '\'';
		return query;
	}
}