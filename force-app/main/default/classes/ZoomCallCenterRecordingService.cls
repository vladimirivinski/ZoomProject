public with sharing class ZoomCallCenterRecordingService {
	// @AuraEnabled
	public static String getPhoneCallRecording(String callId, String recordId) {
		String address = 'callout:ZoomPhone/contact_center/engagements/' + callId + '/recordings';
		HttpRequest req = new HttpRequest();
		Http http = new Http();
		req.setEndpoint(address);
		req.setHeader('Content-type', 'application/json');
		req.setMethod('GET');
		HttpResponse res = http.send(req);
		RecordingWrapper wrapper = (RecordingWrapper) JSON.deserialize(res.getBody(), RecordingWrapper.class);

		if (res.getStatusCode() == 200 && !wrapper.recordings.isEmpty()) {
			String downloadUrl = wrapper.recordings[0].download_url;
			updatePhoneCall(downloadUrl, recordId);
			return downloadUrl;
		} else {
			return null;
		}
	}

	public static String updatePhoneCall(String downloadUrl, String recordId) {
		if (downloadUrl != null) {
			Zoom_Phone_Calls_Info__c callInfo = [SELECT Id, Recording_link__c FROM Zoom_Phone_Calls_Info__c WHERE Id = :recordId];
			callInfo.Recording_link__c = downloadUrl;
			update callInfo;
		}
		return downloadUrl;
	}

	public class RecordingWrapper {
		public String next_page_token { get; set; }
		public Integer page_size { get; set; }
		public String frm { get; set; }
		public String to { get; set; }
		public List<Recording> recordings { get; set; }
	}
	public class Recording {
		public String recording_id { get; set; }
		public String engagement_id { get; set; }
		public String queue_id { get; set; }
		public String queue_name { get; set; }
		public Integer recording_duration { get; set; }
		public String recording_start_time { get; set; }
		public String recording_end_time { get; set; }
		public String user_id { get; set; }
		public String display_name { get; set; }
		public String user_email { get; set; }
		public String recording_type { get; set; }
		public String channel_type { get; set; }
		public String direction { get; set; }
		@AuraEnabled
		public String download_url { get; set; }
		public String transcript_url { get; set; }
		public String playback_url { get; set; }
		public String owner_id { get; set; }
		public String owner_name { get; set; }
		public String owner_type { get; set; }
		public String flow_id { get; set; }
		public String flow_name { get; set; }
		public String consumer_number { get; set; }
	}
}
