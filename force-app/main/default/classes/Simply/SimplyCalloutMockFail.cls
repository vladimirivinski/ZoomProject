@isTest
global class SimplyCalloutMockFail implements HttpCalloutMock {
    
	global HttpResponse respond(HttpRequest req) {     
        HttpResponse response = new HttpResponse();
        response.setBody('{"success":0,"failure":1, "salesforceId":"006", "salesforceId":"001"}');
        response.setStatusCode(500);
        return response;
    }

}