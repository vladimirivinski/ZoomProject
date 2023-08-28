@isTest
public class ZoomUsersPhoneInfosBatchHttpCalloutMock implements HttpCalloutMock {
	@TestSetup
	public static void makeData() {
		List<Zoom_Users_Info__c> zoomUsers = ZoomTestDataFactory.createListZoomUsersInfo(2, 'System Administrator', '@some.com');
	}

	public HTTPResponse respond(HTTPRequest request) {
		DateTime now = DateTime.now();
		String nowString = now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setBody(
			'{"call_logs": [{"accepted_by": {"extension_number": "1009","location": "Pontotoc MS","name": "Display name","number_type": 1,"phone_number": "+12055432724"},"answer_start_time": "2021-10-09T16:52:05Z","call_end_time": "2021-10-09T17:20:53Z","call_id": "7017184835983901126","callee_country_code": "1","callee_country_iso_code": "US","callee_did_number": "+12055432724","callee_name": "Callee name","callee_number": "1018","callee_number_type": 1,"callee_number_source": "internal","caller_country_code": "1","caller_country_iso_code": "US","caller_did_number": "+12055432724","caller_name": "Caller name","caller_number": "+12059300920","caller_number_type": 1,"caller_number_source": "internal","caller_billing_reference_id": "ZoomTelecom123456","charge": "$0.0255","client_code": "123","date_time": "'+ nowString +'","direction": "inbound","duration": 20,"forwarded_by": {"extension_number": "1009","extension_type": "user","location": "Glendale     CA","name": "Display name","number_type": 1,"phone_number": "+12055432724"},"forwarded_to": {"extension_number": "1009","location": "Glendale     CA","name": "Display name","number_type": 1,"phone_number": "+12055432724"},"id": "48c1dfd4-91ce-4df5-8495-7c9e33d10869","outgoing_by": {"extension_number": "1009","location": "Glendale     CA","name": "Display name","number_type": 1,"phone_number": "+12055432724"},"path": "pstn","rate": "$0.0255","recording_type": "1","result": "Call connected","site": {"id": "8f71O6rWT8KFUGQmJIFAdQ","name": "Main Site"},"user_id": "DnEopNmXQEGU2uvvzjgojw","hold_time": 5,"waiting_time": 10,"department": "web-api1","cost_center": "cost-center1"}],"from": "2021-10-01","next_page_token": "AmhfoKtF2Ey4TaPg2iZsAcmetRLs2ZY0Sk2","page_count": 2,"page_size": 30,"to": "2021-10-12","total_records": 54}'
		);
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
