public with sharing class ZoomCallTranscriptionController {

    @future(callout=true)
    public static void getCallTranscription(String recordingId) {
  
        String dt = String.valueOf(Date.today());
        String dtBefore = String.valueOf(Date.today().addDays(-25));
        String address = 'callout:ZoomPhone/phone/recording_transcript/download/'+recordingId;

      //construct an HTTP request
      HttpRequest req = new HttpRequest();
      req.setEndpoint(address);
      req.setMethod('GET');
      req.setHeader('Content-type', 'application/json');
      Http http = new Http();
      HttpResponse res = http.send(req);
    }


    @future(callout=true)
    public static void getUserRecordings(String email) {
  
        String dt = String.valueOf(Date.today());
        String dtBefore = String.valueOf(Date.today().addDays(-25));
        String address = 'callout:ZoomPhone/phone/users/'+email+'/recordings';
        String fromTime = '?from=' + dtBefore;
        String toTime = '&to=' + dt ;
        String pageSize = '&page_size=300';
        String url = address + fromTime + toTime + pageSize;

      //construct an HTTP request
      HttpRequest req = new HttpRequest();
      req.setEndpoint(url);
      req.setMethod('GET');
      req.setHeader('Content-type', 'application/json');
      Http http = new Http();
      HttpResponse res = http.send(req);
    }
}