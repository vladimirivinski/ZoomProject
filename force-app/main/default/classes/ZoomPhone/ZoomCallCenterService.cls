public with sharing class ZoomCallCenterService {
    public static List<ZoomCallCenterEntity.VoiceCall> fetchVoiceCallLogs() {
        String baseUrl = 'callout:ZoomPhone/contact_center/voice_calls';
        Integer pageSize = 50;
        DateTime lastHour = DateTime.now().addHours(-2);
        String fromStr = lastHour.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        String toStr = DateTime.now().formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        String fromTime = '&from=' + fromStr;
        String toTime = '&to=' + toStr;

        List<ZoomCallCenterEntity.VoiceCall> callsWrappersList = new List<ZoomCallCenterEntity.VoiceCall>();

        String nextPageToken = null;
        Integer totalRecords = 0;

        do {
            String url = baseUrl + '?page_size=' + pageSize + fromTime + toTime;
            if (nextPageToken != null) {
                url += '&next_page_token=' + nextPageToken;
            }

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(url);

            Http http = new Http();
            HttpResponse response = http.send(req);

            if (response.getStatusCode() == 200) {
                String json = response.getBody();
                ZoomCallCenterEntity.CallsDataWrapper wrapper = ZoomCallCenterEntity.parse(json);
                callsWrappersList.addAll(wrapper.voice_calls);
                totalRecords = wrapper.total_records;
                nextPageToken = wrapper.next_page_token;
            } else {
                nextPageToken = null;
            }
        } while (nextPageToken != null && callsWrappersList.size() < totalRecords);
        return callsWrappersList;
    }

    public static Map<String, List<ZoomCallCenterEntity.VoiceCall>> getCallCenterIdsToLogsMap(){
        List<ZoomCallCenterEntity.VoiceCall> callsWrappersList = fetchVoiceCallLogs();
        Map<String, List<ZoomCallCenterEntity.VoiceCall>> callCenterIdsToLogsMap = new Map<String, List<ZoomCallCenterEntity.VoiceCall>>();

        for(ZoomCallCenterEntity.VoiceCall call : callsWrappersList){
            String userId = call.agents[0].user_id;

            if(userId != null){
                if (!callCenterIdsToLogsMap.containsKey(userId)) {
                    callCenterIdsToLogsMap.put(userId, new List<ZoomCallCenterEntity.VoiceCall>{call});
                } else {
                    callCenterIdsToLogsMap.get(userId).add(call);
                }
            }
        }
        return callCenterIdsToLogsMap;
    }

    public static List<Zoom_Phone_Calls_Info__c> createCallCenterCalls(List<Zoom_Users_Info__c> usrLst) {
        Id recordTypeId = Schema.SObjectType.Zoom_Phone_Calls_Info__c.getRecordTypeInfosByName().get('Call Center').getRecordTypeId();

        Map<String, List<ZoomCallCenterEntity.VoiceCall>> callCenterIdsToLogsMap = getCallCenterIdsToLogsMap();

        Map<String, Zoom_Phone_Calls_Info__c> callsIdZoomInfoMap = new Map<String, Zoom_Phone_Calls_Info__c>();

        for (Zoom_Users_Info__c u : usrLst) {
            List<ZoomCallCenterEntity.VoiceCall> callLogs = callCenterIdsToLogsMap.get(u.Zoom_User_Id__c);

            if (callLogs != null && !callLogs.isEmpty()) {
                for (ZoomCallCenterEntity.VoiceCall callLog : callLogs) {
                    Zoom_Phone_Calls_Info__c info = new Zoom_Phone_Calls_Info__c();
                    info.Name                       = u.Name;
                    info.Zoom_Users_Info__c         = u.Id;
                    info.Email__c                   = u.Email__c;
                    info.RecordTypeId               = recordTypeId;

                    info.Call_Date_Time__c          = callLog.start_time;
                    info.Caller_Number_Source__c    = callLog.caller_number;
                    info.Callee_Number_Source__c    = callLog.callee_number;
                    info.Callee_Name__c             = callLog.consumer_display_name;
                    info.Has_Recording__c           = callLog.recorded;
                    info.Callee_Location__c         = callLog.country_name;
                    info.Call_Result__c             = callLog.result;
                    info.Call_Direction__c          = callLog.direction;
                    info.Duration__c                = callLog.total_duration;
                    info.Call_Id__c                 = callLog.engagement_id;

                    callsIdZoomInfoMap.put(info.Call_Id__c, info);
                }
            }
        }
        List<Zoom_Phone_Calls_Info__c> resultCallsList = ZoomUsersPhoneService.checkDuplicatePhoneCalls(callsIdZoomInfoMap);
        return resultCallsList;
    }
}