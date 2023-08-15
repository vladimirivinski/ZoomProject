public with sharing class ZoomUsersPhoneInfosBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, schedulable {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, Email__c FROM Zoom_Users_Info__c WHERE CreatedDate = TODAY';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Zoom_Users_Info__c> scope) {
        Map<String, Zoom_Phone_Calls_Info__c> callsIdZoomInfoMap = new Map<String, Zoom_Phone_Calls_Info__c>();

        for (Zoom_Users_Info__c usr : scope) {
            HttpResponse res = ZoomUsersPhoneService.zoomPhoneCallsCallout(usr.email__c);
            // System.debug(' \n ^^^^^^^^^^^^^^^^^^^^ RESPONSE BODY ^^^^^^^^^^^^^^^^^^^^ \n' + res.getBody());
            if (res.getStatusCode() == 200) {
                ZoomUsersPhoneEntity wrappedResponse = ZoomUsersPhoneEntity.parse(res.getBody());
                if (wrappedResponse.total_records != null && wrappedResponse.total_records != 0) {
                    for (ZoomUsersPhoneEntity.cls_call_logs val : wrappedResponse.call_logs) {
                        // System.debug('--------------- val -------------- : ' + val);
                        Zoom_Phone_Calls_Info__c info = new Zoom_Phone_Calls_Info__c();
                        info.Name                               = usr.name;
                        info.Zoom_Users_Info__c                 = usr.id;
                        info.Email__c                           = usr.email__c;
                        info.Call_Date_Time__c                  = val.date_time;
                        info.Call_Id__c                         = val.call_id;
                        info.caller_name__c                     = val.caller_name;
                        info.caller_number__c                   = val.caller_number;
                        info.Caller_Number_Source__c            = val.calleer_number_source;
                        info.Callee_Number_Source__c            = val.callee_number_source;
                        info.Callee_Name__c                     = val.callee_number_source;
                        info.Callee_Number__c                   = val.callee_number;
                        info.Callee_Location__c                 = val.callee_location;
                        info.Call_Result__c                     = val.result;
                        info.has_recording__c                   = val.recording_type != null ? true : false;
                        info.recording_Id__c                    = val.recording_id != null ? val.recording_id : null;
                        if (val.direction == 'inbound') {
                            info.Inbound_Call__c                = val.direction;
                            info.Inbound_Call_Duration__c       = val.duration;
                            info.Waiting_Time__c                = val.waiting_time;
                            info.Hold_Time__c = val.hold_time;
                        } else if (val.direction == 'outbound') {
                            info.Outbound_Call__c               = val.direction;
                            info.Outbound_Call_Duration__c      = val.duration;
                        }
                        callsIdZoomInfoMap.put(info.Call_Id__c, info);
                    }
                }
            }
        }

        List<Zoom_Phone_Calls_Info__c> resultCallsList = ZoomUsersPhoneService.checkDuplicatePhoneCalls(callsIdZoomInfoMap);

        insert resultCallsList;
    }
    public void finish(Database.BatchableContext BC) {
    }

    public static void start(Integer mins) {
        string jobName = 'Zoom Phone Calls updater job - ';
        if (mins == 007)
            Database.executeBatch(new ZoomUsersPhoneInfosBatch(), 50);
        else {
            jobName = jobName += mins + ' - ' + DateTime.now().format();
            String sch = '0 '+ String.valueof(mins)+' 5-18 ? * MON-FRI *';
            System.schedule(jobName, sch, new ZoomUsersPhoneInfosBatch());
        }
    }
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new ZoomUsersPhoneInfosBatch(), 50);
    }
}

//Start all batches every 10 minutes
// ZoomUsersPhoneInfosBatch.start(0);
// ZoomUsersPhoneInfosBatch.start(10);
// ZoomUsersPhoneInfosBatch.start(20);
// ZoomUsersPhoneInfosBatch.start(30);
// ZoomUsersPhoneInfosBatch.start(40);
// ZoomUsersPhoneInfosBatch.start(50);

//Id batchJobId = Database.executeBatch(new ZoomUsersPhoneInfosBatch(), 10);