/*
	ChildRelationship.cls
	
	Last Modified April 19 2011
	
	Custom Apex Object to display Child sObject data on CloneListPage.page
*/
public with sharing class ChildRelationship {
	
	private Boolean selected;
	private String objectName;
	private String relationshipName;
	private String fieldName;
	private Boolean masterDetail;
	private Integer recordAmount;
	
	public void setSelected(Boolean selected) {
		this.selected = selected;
	}
	
	public Boolean getSelected() {
		return this.selected;
	}
	
	public void setObjectName(String objectName) {
		this.objectName = objectName;
	}
	
	public String getObjectName() {
		return this.objectName;
	}
	
	public void setRelationshipName(String relationshipName) {
		this.relationshipName = relationshipName;
	}
	
	public String getRelationshipName() {
		return this.relationshipName;
	}
	
	public void setMasterDetail(Boolean masterDetail) {
		this.masterDetail = masterDetail;
	}
	
	public Boolean getMasterDetail() {
		return this.masterDetail;
	}
	
	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}
	
	public String getFieldName() {
		return this.fieldName;
	}
	
	public void setRecordAmount(Integer recordAmount) {
		this.recordAmount = recordAmount;
	}
	
	public Integer getRecordAmount() {
		return this.recordAmount;
	}
}