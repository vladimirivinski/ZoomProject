public without sharing class ZoomUsersInfoTriggerController {
    public static void checkZoomUserInfoState(List<Zoom_Users_Info__c> newUsr, List<Zoom_Users_Info__c> oldUsr) {
        DateTime nowGMT = DateTime.now();
        DateTime nowPST = nowGMT.addHours(-8);
        System.debug(nowPST.hour());

        String statusOld = oldUsr[0].Presence_Status__c;
        String statusNew = newUsr[0].Presence_Status__c;
        if (statusOld != statusNew) {
            DateTime statusModifiedNew = newUsr[0].Status_Updated__c;
            DateTime statusModifiedOld = oldUsr[0].Status_Updated__c;
            Integer durationSeconds = Integer.valueOf((statusModifiedNew.getTime() - statusModifiedOld.getTime()) / (1000));

            // Sets WORKING HOUR 5 - 18
            if (nowPST.hour() >= 5 && nowPST.hour() <= 18) {
                updateZoomUserState(newUsr[0], durationSeconds, statusOld);
            }
            if (Test.isRunningTest()) {
                updateZoomUserState(newUsr[0], durationSeconds, statusOld);
            }
        }
    }

    public static void updateZoomUserState(Zoom_Users_Info__c usr, Integer durationSeconds, String statusOld) {
        switch on statusOld {
            when 'Available' {
                usr.Available__c += durationSeconds;
            }
            when 'Away' {
                usr.Away__c += durationSeconds;
            }
            when 'In_Calendar_Event' {
                usr.In_Calendar_Event__c += durationSeconds;
            }
            when 'In_Meeting' {
                usr.In_Meeting__c += durationSeconds;
            }
            when 'Offline' {
                usr.Offline__c += durationSeconds;
            }
            when 'On_Phone_Call' {
                usr.On_Phone_Call__c += durationSeconds;
            }
            when 'Presenting' {
                usr.Presenting__c += durationSeconds;
            }
            when 'Do_Not_Disturb' {
                usr.Do_Not_Disturb__c += durationSeconds;
            }
        }
    }
    //NOTE: Old version for verifying User_Log_In__c status
    // public static void checkFirstUserLogIn(String statusOld, String statusNew, List<Zoom_Users_Info__c> usr, DateTime statusModifiedNew){
    //     if(statusOld == 'Initial' && (statusNew == 'Available' || statusNew == 'Away' || statusNew == 'On_Phone_Call' || statusNew == 'In_Meeting' || statusNew == 'Presenting' || statusNew == 'In_Calendar_Event')){
    //         usr[0].User_Log_In__c = Datetime.now();
    //     }
    // }
}

// oldUsr
// (Zoom_Users_Info__c:{Id=a4cDF0000006TbwYAE,
//      OwnerId=0051G000008D1IPQA0,
//      IsDeleted=false,
//      Name=Rebecca Unutoa,
//      CreatedDate=2023-01-05 19:04:12,
//      CreatedById=0051G000008D1IPQA0,
//      LastModifiedDate=2023-01-05 22:43:5z4,
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