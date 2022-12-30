trigger ZoomUsersInfoTrigger on Zoom_Users_Info__c (before insert, before update, before delete, after insert, after update, after delete){

    ZoomUsersInfoTriggerHandler handler = New ZoomUsersInfoTriggerHandler();

    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('**** Trigger.New ******: ' + Trigger.New);
        System.debug('**** Trigger.Old ******: ' + Trigger.Old);

    }
    else if(Trigger.isInsert && Trigger.isAfter){
        System.debug('**** Trigger.New ******: ' + Trigger.New);
        System.debug('**** Trigger.Old ******: ' + Trigger.Old);

    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.New, Trigger.Old);
        System.debug('**** Trigger.New ****** Trigger.isUpdate && Trigger.isBefore: ' + Trigger.New);
        System.debug('**** Trigger.Old ****** Trigger.isUpdate && Trigger.isBefore: ' + Trigger.Old);
        System.debug('****Time Now ****** : ' + DateTime.now());


    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        // handler.OnAfterUpdate(Trigger.New, Trigger.Old);
        System.debug('**** Trigger.New ******: ' + Trigger.New);    
        System.debug('**** Trigger.Old ******: ' + Trigger.Old);

    }
    else if(Trigger.isDelete && Trigger.isBefore){
        System.debug('**** Trigger.New ******: ' + Trigger.New);
        System.debug('**** Trigger.Old ******: ' + Trigger.Old);

    }
    else if(Trigger.isDelete && Trigger.isAfter){
        System.debug('**** Trigger.New ******: ' + Trigger.New);
        System.debug('**** Trigger.Old ******: ' + Trigger.Old);

    }

}
