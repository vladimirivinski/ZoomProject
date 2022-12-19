public with sharing class ZoomAPIs {

    // public static void get() {
    //     String endPoint = 'callout:ZoomPhone/phone/call_logs';
    //     HttpRequest req = new HttpRequest();
    //     req.setMethod('GET');
    //     req.setHeader('Content-type', 'application/json');
    //     req.setEndpoint(endPoint); 
    //     Http http = new Http();
    //     HttpResponse res = http.send(req);
    //         System.debug('res ' +res);            
    //         System.debug('res pass >>>' +res.getBody());            
    // }

    public static void get(String userEmail) {
        String endPoint = 'callout:ZoomMeeting/users/'+userEmail+'/meetings';
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(endPoint); 
        Http http = new Http();
        HttpResponse res = http.send(req);
            System.debug('res ' +res);            
            System.debug('res pass >>>' +res.getBody());            
    }
}