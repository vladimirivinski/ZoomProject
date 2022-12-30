public without sharing class ZoomUsersInfoTriggerController {
    public static void checkZoomUserInfoState(List<Zoom_Users_Info__c> newUsr, List<Zoom_Users_Info__c> oldUsr ){
        System.debug('****************oldUsr**************** '+ oldUsr);
        System.debug('****************newUsr**************** '+ newUsr);
        String stateOld = oldUsr[0].Presence_Status__c;
        String stateNew = newUsr[0].Presence_Status__c;
        if(stateOld != stateNew){
            DateTime modifiedNew = newUsr[0].Status_Updated__c;
            DateTime modifiedOld = oldUsr[0] == null ? DateTime.now() : oldUsr[0].Status_Updated__c;
            Decimal durationSeconds = Integer.valueOf((modifiedNew.getTime() - modifiedOld.getTime())/(60000));
            System.debug('****************modifiedNew**************** '+ modifiedNew);
            System.debug('****************modifiedOld**************** '+ modifiedOld);
            System.debug('****************durationSeconds**************** '+ durationSeconds);
            updateZoomUserState(newUsr, durationSeconds, stateOld);
        }
        System.debug('****************stateNew**************** '+ stateNew);
        System.debug('****************stateOld**************** '+ stateOld);

    }


    public static void updateZoomUserState(List<Zoom_Users_Info__c> usr, Decimal durationSeconds, String stateOld){
        switch on stateOld {
            when 'Available' {
                System.debug('######### Available ######### /n ');
                usr[0].Available__c += durationSeconds;
            }
            when 'Away' {
                System.debug('######### Away ######### /n ');
                usr[0].Away__c += durationSeconds;
            }
            when 'In_Calendar_Event' {
                System.debug('######### In_Calendar_Event ######### /n ');
                usr[0].In_Calendar_Event__c += durationSeconds;
            }
            when 'In_Meeting' {
                System.debug('######### In_Meeting ######### /n ');
                usr[0].In_Meeting__c += durationSeconds;
            }
            when 'Offline' {
                System.debug('######### Offline ######### /n ');
                usr[0].Offline__c += durationSeconds;
            }
            when 'On_Phone_Call' {
                System.debug('######### On_Phone_Call ######### /n ');
                usr[0].On_Phone_Call__c += durationSeconds;
            }
            when 'Presenting' {
                System.debug('######### Presenting ######### /n ');
                usr[0].Presenting__c += durationSeconds;
            }
            when 'Do_Not_Disturb' {
                System.debug('######### Do_Not_Disturb ######### /n ');
                usr[0].Do_Not_Disturb__c += durationSeconds;
            }
        } 
    }
}




// (Zoom_Users_Info__c:
// {Id=a4cDF0000006Rw9YAE,
//     OwnerId=0051G000008D1IPQA0,
//     IsDeleted=false,
//     Name=Krystal Burgess,
//     CreatedDate=2022-12-27 08:00:11,
//     CreatedById=0051G000008D1IPQA0,
//     LastModifiedDate=2022-12-27 20:15:27,
//     LastModifiedById=005DF000007oUWBYA2,
//     SystemModstamp=2022-12-27 20:15:27,
//     LastActivityDate=null,
//     LastViewedDate=null,
//     LastReferencedDate=null,
//     User_Log_In__c=null,
//     User_Log_Out__c=null,
//     Available__c=null,
//     Away__c=null,
//     Offline__c=null,
//     Email__c=kburgess@myubiquity.com,
//     Tracking_Date__c=2022-12-27 00:00:00,
//     In_Meeting__c=null,
//     In_Calendar_Event__c=null,
//     Do_Not_Disturb__c=null,
//     On_Phone_Call__c=null,
//     Presence_Status__c=Available,
//     Inbound_Calls__c=5,
//     Outbound_Calls__c=1,
//     User__c=00537000003l1LCAAY,
//     LogIn__c=2022-12-27 18:43:27,
//     LogOut__c=2022-12-27 18:34:16
// })