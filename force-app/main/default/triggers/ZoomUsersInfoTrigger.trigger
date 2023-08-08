trigger ZoomUsersInfoTrigger on Zoom_Users_Info__c (before insert, before update, before delete, after insert, after update, after delete){

    ZoomUsersInfoTriggerHandler handler = New ZoomUsersInfoTriggerHandler();

    if(Trigger.isInsert && Trigger.isBefore){

    }
    else if(Trigger.isInsert && Trigger.isAfter){

    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.New, Trigger.Old);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){

    }

}