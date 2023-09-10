public with sharing class ZoomRecordingsController {
    @AuraEnabled
    public static String checkCallType(String callId, String recordId, String recordTypeId){
        if(recordTypeId == '012D4000001LyuFIAS'){
            return ZoomPhoneCallRecordingService.getPhoneCallRecording(callId, recordId);
        }
        if(recordTypeId == '012D4000001LyuAIAS'){
            return ZoomCallCenterRecordingService.getPhoneCallRecording(callId, recordId);
        }
        return null;
    }
}