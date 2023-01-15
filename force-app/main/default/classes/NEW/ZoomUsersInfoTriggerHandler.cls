public without sharing class ZoomUsersInfoTriggerHandler {
    
    public void OnBeforeInsert (List<Zoom_Users_Info__c> newUsr, List<Zoom_Users_Info__c> oldUsr){

    } 
    public void OnAfterInsert (List<Zoom_Users_Info__c> newUsr, List<Zoom_Users_Info__c> oldUsr){
        
    } 
    public void OnBeforeUpdate (List<Zoom_Users_Info__c> newUsr, List<Zoom_Users_Info__c> oldUsr){
        ZoomUsersInfoTriggerController.checkZoomUserInfoState(newUsr, oldUsr);
    } 
    public void OnAfterUpdate (List<Zoom_Users_Info__c> newUsr, List<Zoom_Users_Info__c> oldUsr){
        
    } 
    public void OnBeforeDelete (List<Zoom_Users_Info__c> newUsr, List<Zoom_Users_Info__c> oldUsr){

    } 
    public void OnAfterDelete (List<Zoom_Users_Info__c> newUsr, List<Zoom_Users_Info__c> oldUsr){

    } 

}
