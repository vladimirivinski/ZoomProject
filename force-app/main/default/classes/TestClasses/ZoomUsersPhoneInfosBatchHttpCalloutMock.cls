@isTest
public class ZoomUsersPhoneInfosBatchHttpCalloutMock implements HttpCalloutMock{
    @TestSetup
    public static void makeData(){
        List<Zoom_Users_Info__c> zoomUsers = ZoomTestDataFactory.createListZoomUsersInfo(3, 'System Administrator', '@myubiquity.com');
    }

    public HTTPResponse respond(HTTPRequest request) {
        DateTime now = DateTime.now();
        String nowString = now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"total_records":2,"call_logs":[{"call_id":"123","Email":"testuser0@myubiquity.com", "caller_name":"John Smith","caller_number":"555-555-5555","date_time":"' + nowString + '","direction":"inbound","duration":60,"result":"Auto Recorded","recording_id":"e0220382054f4d8882127bc3e50c48c1","recording_type":"mp4"},{"call_id":"456","Email":"testuser1@myubiquity.com","caller_name":"Jane Doe","caller_number":"555-555-5556","date_time":"' + nowString + '","direction":"outbound","duration":90,"result":"Call connected"}]}');
        response.setStatusCode(200);
        return response; 
    }

    @isTest
    public static void testBatch() {
        Test.setMock(HttpCalloutMock.class, new ZoomUsersPhoneInfosBatchHttpCalloutMock());
        Test.startTest();
        Database.executeBatch(new ZoomUsersPhoneInfosBatch());
        Test.stopTest();
        List<Zoom_Phone_Calls_Info__c> calls = [SELECT Name, Zoom_Users_Info__c, Email__c, Call_Result__c FROM Zoom_Phone_Calls_Info__c WHERE Email__c LIKE :'%testuser%'];
        System.assertEquals(2, calls.size(), 'Should create 2 phone call records');
    }

    @isTest
    public static void testScheduler(){
        Test.setMock(HttpCalloutMock.class, new ZoomUsersPhoneInfosBatchHttpCalloutMock());
        Test.startTest();
        ZoomUsersPhoneInfosBatch.start(007);
        ZoomUsersPhoneInfosBatch.start(0);
        Test.stopTest();
        List<Zoom_Phone_Calls_Info__c> calls = [SELECT Name, Zoom_Users_Info__c, Email__c, Call_Result__c FROM Zoom_Phone_Calls_Info__c WHERE Email__c LIKE :'%testuser%'];
        System.assertEquals(2, calls.size(), 'Should create 2 phone call records'); 
    }
}