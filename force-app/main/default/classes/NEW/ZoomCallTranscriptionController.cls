public with sharing class ZoomCallTranscriptionController {

    @AuraEnabled(cacheable=true)
    public static ServiceResponse getCallTranscription(String recordingId) {
		ServiceResponse result;
		if(recordingId == null){
			return null;
		} else{
			String address = 'callout:ZoomPhone/phone/recording_transcript/download/'+recordingId;
			HttpRequest req = new HttpRequest();
			Http http = new Http();
			req.setEndpoint(address);
			req.setHeader('Content-type', 'application/json');
			req.setMethod('GET');
			HttpResponse res = http.send(req);
			String transcript;
			if (res.getStatusCode() == 200) {
				transcript = res.getBody();	
				result = (ServiceResponse) JSON.deserialize(transcript, ServiceResponse.class);	
			} else if(res.getStatusCode() == 302) {
				String redirectUrl = res.getHeader('location');
				req.setEndpoint(redirectUrl);
				res = http.send(req);
				transcript = res.getBody();
				result = (ServiceResponse) JSON.deserialize(transcript, ServiceResponse.class);
			} else {
			  System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
			}
			return result;
		}
    }

	public class ServiceResponse {
		@AuraEnabled
		public String type {get; set;}
		@AuraEnabled
		public Integer ver {get; set;}
		@AuraEnabled
		public String recording_id {get; set;}
		@AuraEnabled
		public String meeting_id {get; set;}
		@AuraEnabled
		public String account_id {get; set;}
		@AuraEnabled
		public String host_id {get; set;}
		@AuraEnabled
		public String recording_start {get; set;}
		@AuraEnabled
		public String recording_end {get; set;}
		@AuraEnabled
		public List<Timeline> timeline {get; set;}
	}
	
	public class Timeline {
		@AuraEnabled
		public String text {get; set;}
		@AuraEnabled
		public String end_ts {get; set;}
		@AuraEnabled
		public String ts {get; set;}
		@AuraEnabled
		public List<Users> users {get; set;}
	}
	
	public class Users {
		@AuraEnabled
		public String username {get; set;}
		@AuraEnabled
		public Boolean multiple_people {get; set;}
		@AuraEnabled
		public String user_id {get; set;}
		@AuraEnabled
		public String zoom_userid {get; set;}
		@AuraEnabled
		public Integer client_type {get; set;}
	}
}
