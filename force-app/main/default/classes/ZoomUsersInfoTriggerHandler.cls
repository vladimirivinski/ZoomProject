public with sharing class ZoomUsersInfoTriggerHandler {
    private Boolean isExecuting = false;
    public ZoomUsersInfoTrigger(Boolean isExecuting){
        this.isExecuting = isExecuting;
    }
    
    public void OnBeforeInsert (List<Zoom_Users_Info__c> obj){

    } 
    public void OnAfterInsert (List<Zoom_Users_Info__c> obj){

    } 
    public void OnBeforeUpdate (List<Zoom_Users_Info__c> obj){

    } 
    public void OnAfterUpdate (List<Zoom_Users_Info__c> obj){

    } 
    public void OnBeforeDelete (List<Zoom_Users_Info__c> obj){

    } 
    public void OnAfterDelete (List<Zoom_Users_Info__c> obj){

    } 

    public Boolean IsTriggerContext{
        get{ return isExecuting; }
    }
}
