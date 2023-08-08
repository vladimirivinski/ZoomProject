@isTest
public with sharing class ZoomCallTranscriptionControllerTest implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        String recordingId = '1234567';

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('location', 'https://api.zoom.us/v2/recordings/' + recordingId + '/transcript');
        response.setBody('{"ver":2,"recording_id":"' + recordingId + '","meeting_id":"12345678","timeline":[{"text":"test transcription","users":[{"username":"testuser"}]}]}');
        response.setStatusCode(200);
        return response;
    }
    @isTest
    public static void getCallTranscriptionStatusTest() {
        String recordingId = '1234567';
        Test.setMock(HttpCalloutMock.class, new ZoomCallTranscriptionControllerTest());
        Test.startTest();
        ZoomCallTranscriptionController.ServiceResponse result = ZoomCallTranscriptionController.getCallTranscription(recordingId);
        Test.stopTest();
        System.assertEquals(2, result.ver, 'The ver should be 2');
        System.assertEquals(recordingId, result.recording_id, 'The recording_id should be 1234567');
    }

    @isTest
    public static void getCallTranscriptionTest() {
        Test.setMock(HttpCalloutMock.class, new ZoomCallTranscriptionHttpCalloutMock());
        String recordingId = '123456';
        Test.startTest();
        ZoomCallTranscriptionController.ServiceResponse result = ZoomCallTranscriptionController.getCallTranscription(recordingId);
        Test.stopTest();

        System.assertEquals('transcription', result.type, 'The type should be transcription');
        System.assertEquals(1, result.ver, 'The ver should be 1');
        System.assertEquals(recordingId, result.recording_id, 'The recording_id should be 123456');
        System.assertEquals('12345678', result.meeting_id, 'The meeting_id should be 12345678');
        System.assertEquals('123456789', result.account_id, 'The account_id should be 123456789');
        System.assertEquals('testhost', result.host_id, 'The host_id should be testhost');
        System.assertEquals('2022-01-01T00:00:00Z', result.recording_start, 'The recording_start should be 2022-01-01T00:00:00Z');
        System.assertEquals('2022-01-01T01:00:00Z', result.recording_end, 'The recording_end should be 2022-01-01T01:00:00Z');

        System.assertEquals('test transcription', result.timeline[0].text, 'The text should be test transcription');
        System.assertEquals('2022-01-01T00:30:00Z', result.timeline[0].end_ts, 'The end_ts should be 2022-01-01T00:30:00Z');
        System.assertEquals('2022-01-01T00:00:00Z', result.timeline[0].ts, 'The ts should be 2022-01-01T00:00:00Z');

        System.assertEquals('testuser', result.timeline[0].users[0].username, 'The username should be testuser');
        System.assertEquals(false, result.timeline[0].users[0].multiple_people, 'The multiple_people should be false');
        System.assertEquals('testuserid', result.timeline[0].users[0].user_id, 'The user_id should be testuserid');
        System.assertEquals('testzoomuserid', result.timeline[0].users[0].zoom_userid, 'The zoom_userid should be testzoomuserid');
        System.assertEquals(1, result.timeline[0].users[0].client_type, 'The client_type should be 1');
    }

    @isTest
    public static void getCallTranscriptionNullIdTest() {
        String recordingId;
        Test.startTest();
        ZoomCallTranscriptionController.ServiceResponse result = ZoomCallTranscriptionController.getCallTranscription(recordingId);
        Test.stopTest();
    }
}