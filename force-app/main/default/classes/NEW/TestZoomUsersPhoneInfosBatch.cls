@isTest
public class TestZoomUsersPhoneInfosBatch {

    static testMethod void testBatch() {
        // Create test data for Zoom_Users_Info__c
        List<Zoom_Users_Info__c> zoomUsers = new List<Zoom_Users_Info__c>();
        for(Integer i=0; i<2; i++) {
            Zoom_Users_Info__c zoomUser = new Zoom_Users_Info__c();
            zoomUser.Name = 'Test User ' + i;
            zoomUser.Email__c = 'testuser' + i + '@test.com';
            zoomUsers.add(zoomUser);
        }
        insert zoomUsers;
        
        // Create a mocked version of the HttpResponse
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"total_records":2,"call_logs":[{"date_time":"2022-01-11T12:00:00Z","call_id":"12345","caller_name":"John Smith","caller_number":"(123) 456-7890","duration":"600","type":"audio","status":"completed"}]}');
        
        // Create a mock version of the Http class
        Test.startTest();
        Http mockHttp = Test.createMock(Http.class);
        Test.setMock(Http.class, mockHttp);
        mockHttp.send(new HttpRequest()).returns(mockResponse);

        
        // Create a new instance of the batch class
        ZoomUsersPhoneInfosBatch batch = new ZoomUsersPhoneInfosBatch();
        // Execute the batch
        Database.executeBatch(batch);

        // Verify the call logs were inserted
        List<Zoom_Phone_Calls_Info__c> callLogs = [SELECT Id FROM Zoom_Phone_Calls_Info__c];
        System.assertEquals(2, callLogs.size());
        Test.stopTest();
    }
}
