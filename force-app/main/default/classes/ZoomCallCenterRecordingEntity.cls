public with sharing class ZoomCallCenterRecordingEntity {

	public static RecordingDataWrapper parse(String json){
		return (RecordingDataWrapper) System.JSON.deserialize(json, RecordingDataWrapper.class);
	}

    public class RecordingDataWrapper{
        public String next_page_token { get;set; }
	    public Integer page_size { get;set; }
	    public String frm { get;set; }
	    public String to { get;set; }
	    public List<RecordingData> recordings;
    }

	public class RecordingData {
		@AuraEnabled
        public String recording_id { get;set; }
		@AuraEnabled
        public String queue_id { get;set; }
		@AuraEnabled
        public String queue_name { get;set; }
		@AuraEnabled
        public Integer recording_duration { get;set; }
		@AuraEnabled
        public String download_url { get;set; }
		@AuraEnabled
        public String transcript_url { get;set; }
		@AuraEnabled
        public String playback_url { get;set; }
		@AuraEnabled
        public String recording_start_time { get;set; }
		@AuraEnabled
        public String recording_end_time { get;set; }
		@AuraEnabled
        public String user_id { get;set; }
		@AuraEnabled
        public String user_email { get;set; }
		@AuraEnabled
        public String display_name { get;set; }
		@AuraEnabled
        public String recording_type { get;set; }
		@AuraEnabled
        public String channel_type { get;set; }
		@AuraEnabled
        public String direction { get;set; }
		@AuraEnabled
        public String owner_id { get;set; }
		@AuraEnabled
        public String owner_name { get;set; }
		@AuraEnabled
        public String owner_type { get;set; }
		@AuraEnabled
        public String engagement_id { get;set; }
		@AuraEnabled
        public String flow_name { get;set; }
		@AuraEnabled
        public String flow_id { get;set; }
		@AuraEnabled
        public Consumers[] consumers;
	}
	public class Consumers {
		@AuraEnabled
        public String consumer_name { get;set; }
		@AuraEnabled
        public String consumer_number { get;set; }
	}
}



// System.debug('recording_id'+ rec.recordings.recording_id);
// System.debug('queue_id'+ rec.recordings.queue_id);
// System.debug('queue_name'+ rec.recordings.queue_name);
// System.debug('recording_duration'+ rec.recordings.recording_duration);
// System.debug('download_url'+ rec.recordings.download_url);
// System.debug('transcript_url'+ rec.recordings.transcript_url);
// System.debug('playback_url'+ rec.recordings.playback_url);
// System.debug('recording_start_time'+ rec.recordings.recording_start_time);
// System.debug('recording_end_time'+ rec.recordings.recording_end_time);
// System.debug('user_id'+ rec.recordings.user_id);
// System.debug('user_email'+ rec.recordings.user_email);
// System.debug('display_name'+ rec.recordings.display_name);
// System.debug('recording_type'+ rec.recordings.recording_type);
// System.debug('channel_type'+ rec.recordings.channel_type);
// System.debug('direction'+ rec.recordings.direction);
// System.debug('owner_id'+ rec.recordings.owner_id);
// System.debug('owner_name'+ rec.recordings.owner_name);
// System.debug('owner_type'+ rec.recordings.owner_type);
// System.debug('engagement_id'+ rec.recordings.engagement_id);
// System.debug('flow_name'+ rec.recordings.flow_name);
// System.debug('flow_id'+ rec.recordings.flow_id);
