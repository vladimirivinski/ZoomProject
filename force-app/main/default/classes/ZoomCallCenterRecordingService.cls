public with sharing class ZoomCallCenterRecordingService {
    @AuraEnabled(cacheable=true)
    public static String getEngagementRecording(String callId, String recordId) {
        ZoomCallCenterRecordingEntity.RecordingDataWrapper result;
        if (callId == null) {
            return null;
        } else {
            String address = 'callout:ZoomPhone/contact_center/engagements/'+callId+'/recordings';
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setEndpoint(address);
            req.setHeader('Content-type', 'application/json');
            req.setMethod('GET');
            HttpResponse res = http.send(req);
            String responseBody;
            if (res.getStatusCode() == 200) {
                responseBody = res.getBody();
            } else if (res.getStatusCode() == 302) {
                String redirectUrl = res.getHeader('location');
                req.setEndpoint(redirectUrl);
                res = http.send(req);
                responseBody = res.getBody();
            } else {
                System.debug('Error: ' + res.getBody() );
                System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
            return parseData(responseBody, recordId);
        }
    }

    public static String parseData (String responseBody, String recordId){
        ZoomCallCenterRecordingEntity.RecordingDataWrapper wrapper = (ZoomCallCenterRecordingEntity.RecordingDataWrapper) JSON.deserialize(responseBody, ZoomCallCenterRecordingEntity.RecordingDataWrapper.class);
        List<Zoom_Phone_Calls_Info__c> usrList = [SELECT Id, Recording_Id__c, Call_Type__c FROM Zoom_Phone_Calls_Info__c WHERE  Id= :recordId LIMIT 1];
        String result       = null;
        String recordingId  = null;
        String callType     = null;
        for (ZoomCallCenterRecordingEntity.RecordingData rec : wrapper.recordings) {
            recordingId = rec.recording_id;
            callType    = rec.channel_type;
            break;
        }
        if(recordingId != null && callType != null){
            // usrList[0].Recording_Id__c  = recordingId;
            // usrList[0].Call_Type__c     = callType;
            // update usrList;
            result = getRecordingTranscript(recordingId, callType);
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordingTranscript(String recordingId, String callType){
        String address = 'callout:ZoomPhone/contact_center/recording/transcripts/download/' + recordingId + '?type=' + callType;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setEndpoint(address);
        req.setHeader('Content-type', 'application/json');
        req.setMethod('GET');
        HttpResponse response = http.send(req);

        String contentType = response.getHeader('Content-Type');
        // System.debug('Content-Type: ' + contentType);
        // System.debug('========'+response.getBody());

        return response.getBody();
    }
}