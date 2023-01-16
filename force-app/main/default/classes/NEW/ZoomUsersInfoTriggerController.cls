public without sharing class ZoomUsersInfoTriggerController {
    public static void checkZoomUserInfoState(List<Zoom_Users_Info__c> newUsr, List<Zoom_Users_Info__c> oldUsr) {
        // System.debug('\n**************** oldUsr **************** \n'+ oldUsr);
        // System.debug('\n**************** newUsr **************** \n'+ newUsr);
        String statusOld = oldUsr[0].Presence_Status__c;
        String statusNew = newUsr[0].Presence_Status__c;
        // System.debug('\n**************** statusNew **************** \n'+ statusNew);
        // System.debug('\n**************** statusOld **************** \n'+ statusOld);
        if (statusOld != statusNew) {
            DateTime statusModifiedNew = newUsr[0].Status_Updated__c; // !!!!!!!!!!!!!!!! CHECK THIS
            DateTime statusModifiedOld = oldUsr[0].Status_Updated__c; // !!!!!!!!!!!!!!!! CHECK THIS
            Integer durationSeconds = Integer.valueOf((statusModifiedNew.getTime() - statusModifiedOld.getTime()) / (1000)); // in minutes
            // System.debug('\n**************** statusModifiedNew **************** \n'+ statusModifiedNew);
            // System.debug('\n**************** statusModifiedOld **************** \n'+ statusModifiedOld);
            // System.debug('\n**************** statusModifiedNew.getTime() **************** \n'+ statusModifiedNew.getTime());
            // System.debug('\n**************** statusModifiedOld.getTime() **************** \n'+ statusModifiedOld.getTime());
            // System.debug('\n**************** durationSeconds **************** \n'+ durationSeconds);
            updateZoomUserState(newUsr, durationSeconds, statusOld);
            checkFirstUserLogIn(statusOld, statusNew, newUsr, statusModifiedNew);
        }
    }

    public static void updateZoomUserState(List<Zoom_Users_Info__c> usr, Integer durationSeconds, String statusOld) {
        switch on statusOld {
            when 'Available' {
                // System.debug('######### Available ######### /n ');
                usr[0].Available__c += durationSeconds;
            }
            when 'Away' {
                // System.debug('######### Away ######### /n ');
                usr[0].Away__c += durationSeconds;
            }
            when 'In_Calendar_Event' {
                // System.debug('######### In_Calendar_Event ######### /n ');
                usr[0].In_Calendar_Event__c += durationSeconds;
            }
            when 'In_Meeting' {
                // System.debug('######### In_Meeting ######### /n ');
                usr[0].In_Meeting__c += durationSeconds;
            }
            when 'Offline' {
                // System.debug('######### Offline ######### /n ');
                usr[0].Offline__c += durationSeconds;
            }
            when 'On_Phone_Call' {
                // System.debug('######### On_Phone_Call ######### /n ');
                usr[0].On_Phone_Call__c += durationSeconds;
            }
            when 'Presenting' {
                // System.debug('######### Presenting ######### /n ');
                usr[0].Presenting__c += durationSeconds;
            }
            when 'Do_Not_Disturb' {
                // System.debug('######### Do_Not_Disturb ######### /n ');
                usr[0].Do_Not_Disturb__c += durationSeconds;
            }
        }
    }

    public static void checkFirstUserLogIn(String statusOld, String statusNew, List<Zoom_Users_Info__c> usr, DateTime statusModifiedNew) {
        if (statusOld == 'Initial' && (statusNew == 'Available' || statusNew == 'Away' || statusNew == 'On_Phone_Call' || statusNew == 'In_Meeting' || statusNew == 'Presenting' || statusNew == 'In_Calendar_Event')) {
            usr[0].User_Log_In__c = statusModifiedNew;
        }
    }
}

// oldUsr
// (Zoom_Users_Info__c:{Id=a4cDF0000006TbwYAE,
//      OwnerId=0051G000008D1IPQA0,
//      IsDeleted=false,
//      Name=Rebecca Unutoa,
//      CreatedDate=2023-01-05 19:04:12,
//      CreatedById=0051G000008D1IPQA0,
//      LastModifiedDate=2023-01-05 22:43:54,
//      LastModifiedById=005DF000007oUWBYA2,
//      SystemModstamp=2023-01-05 22:43:54,
//      LastActivityDate=null,
//      LastViewedDate=null,
//      LastReferencedDate=null,
//      ConnectionReceivedId=null,
//      ConnectionSentId=null,
//      User_Log_In__c=null,
//      User_Log_Out__c=null,
//      Available__c=40.00,
//      Away__c=0.00,
//      Offline__c=66.00,
//      Zoom_Phone_Calls_Info__c=null,
//      Email__c=runutoa@myubiquity.com,
//      Total_Inbound_Calls__c=9,
//      Tracking_Date__c=2023-01-05 00:00:00,
//      In_Meeting__c=0.00,
//      In_Calendar_Event__c=6.00,
//      Do_Not_Disturb__c=0.00,
//      On_Phone_Call__c=40.00,
//      Presence_Status__c=Available,
//      User__c=0051G0000076tPRQAY,
//      LogIn__c=null,
//      LogOut__c=null,
//      Presenting__c=0.00,
//      Status_Updated__c=2023-01-05 22:43:54,
//      Total_Outbound_Calls__c=2,
//      Total_Inbound_Calls_Duration__c=35,
//      Total_Outbound_Calls_Duration__c=11,
//      AHT_Inbound__c=3.89,
//      AHT_Outbound__c=5.50})

// newUsr
// (Zoom_Users_Info__c:{Id=a4cDF0000006TbwYAE,
//      OwnerId=0051G000008D1IPQA0,
//      IsDeleted=false,
//      Name=Rebecca Unutoa,
//      CreatedDate=2023-01-05 19:04:12,
//      CreatedById=0051G000008D1IPQA0,
//      LastModifiedDate=2023-01-05 22:43:54,
//      LastModifiedById=005DF000007oUWBYA2,
//      SystemModstamp=2023-01-05 22:43:54,
//      LastActivityDate=null,
//      LastViewedDate=null,
//      LastReferencedDate=null,
//      ConnectionReceivedId=null,
//      ConnectionSentId=null,
//      User_Log_In__c=null,
//      User_Log_Out__c=null,
//      Available__c=40.00,
//      Away__c=0.00,
//      Offline__c=66.00,
//      Zoom_Phone_Calls_Info__c=null,
//      Email__c=runutoa@myubiquity.com,
//      Total_Inbound_Calls__c=9,
//      Tracking_Date__c=2023-01-05 00:00:00,
//      In_Meeting__c=0.00,
//      In_Calendar_Event__c=6.00,
//      Do_Not_Disturb__c=0.00,
//      On_Phone_Call__c=40.00,
//      Presence_Status__c=On_Phone_Call,
//      User__c=0051G0000076tPRQAY,
//      LogIn__c=null,
//      LogOut__c=null,
//      Presenting__c=0.00,
//      Status_Updated__c=2023-01-05 22:44:46,
//      Total_Outbound_Calls__c=2,
//      Total_Inbound_Calls_Duration__c=35,
//      Total_Outbound_Calls_Duration__c=11,
//      AHT_Inbound__c=3.89,
//      AHT_Outbound__c=5.50})

