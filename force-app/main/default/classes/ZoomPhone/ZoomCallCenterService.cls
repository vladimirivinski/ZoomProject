public with sharing class ZoomCallCenterService {
    public static List<ZoomCallCenterEntity.VoiceCall> fetchVoiceCallLogs() {
        String baseUrl = 'callout:ZoomPhone/contact_center/voice_calls';
        Integer pageSize = 50;
        DateTime lastHour = DateTime.now().addDays(-1);
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

    public static Map<String, ZoomCallCenterEntity.VoiceCall> getCallCenterIdsToLogsMap(){
        List<ZoomCallCenterEntity.VoiceCall> callsWrappersList = fetchVoiceCallLogs();
        Map<String, ZoomCallCenterEntity.VoiceCall> callCenterIdsToLogsMap = new Map<String, ZoomCallCenterEntity.VoiceCall>();
        for(ZoomCallCenterEntity.VoiceCall call : callsWrappersList){
            String userId = call.agents[0].user_id;
            callCenterIdsToLogsMap.put(userId, call);
        }
        System.debug('callCenterIdsToLogsMap:!!!! ' + callCenterIdsToLogsMap);

        for(String o :callCenterIdsToLogsMap.keySet()){
            System.debug('String ' + o);
            System.debug('OBJECT ' + callCenterIdsToLogsMap.get(o));

        }
        return callCenterIdsToLogsMap;
    }
}