public with sharing class ZoomCallCenterService {
    public static List<ZoomCallCenterEntity.VoiceCall> fetchVoiceCallLogs() {
        String baseUrl = 'callout:ZoomPhone/contact_center/voice_calls';
        Integer pageSize = 100;
        DateTime lastHour = DateTime.now().addHours(-12);
        String fromStr = lastHour.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        String toStr = DateTime.now().formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        String fromTime = '?from=' + fromStr;
        String toTime = '&to=' + toStr;

        List<ZoomCallCenterEntity.VoiceCall> callsWrappersList = new List<ZoomCallCenterEntity.VoiceCall>();

        String nextPageToken = null;
        Integer totalRecords = 0;

        do {
            String url = baseUrl + fromTime + toTime + '&page_size=' + pageSize;
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
                System.debug('Callout failed with status code: ' + response.getStatusCode());
                nextPageToken = null;
            }
        } while (nextPageToken != null && callsWrappersList.size() < totalRecords);
        return callsWrappersList;
    }
}