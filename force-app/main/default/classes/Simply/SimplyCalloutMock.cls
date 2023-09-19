@isTest
global class SimplyCalloutMock implements HttpCalloutMock {
    
	global HttpResponse respond(HttpRequest req) {
        HttpResponse response = new HttpResponse();
        response.setBody('{"success":1,"failure":0, "salesforceId":"006", "salesforceId":"001"}');
        response.setStatusCode(200);
        return response;
    }
}