public without sharing class ZoomUsersInfoTriggerHandler {
    //NOTE: Create new conditions for the trigger to fire controllers

    public void OnBeforeUpdate(List<Zoom_Users_Info__c> newUsr, List<Zoom_Users_Info__c> oldUsr) {
        ZoomUsersInfoTriggerController.checkZoomUserInfoState(newUsr, oldUsr);
    }
}