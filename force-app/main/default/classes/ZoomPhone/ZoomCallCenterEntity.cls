public with sharing class ZoomCallCenterEntity {

    public static CallsDataWrapper parse(String json){
        return (CallsDataWrapper) System.JSON.deserialize(json, CallsDataWrapper.class);
    }

    public class CallsDataWrapper {
		public String next_page_token { get; set; }
		public Integer page_size { get; set; }
		public Integer total_records { get; set; }
		public DateTime frm { get; set; }
		public DateTime to { get; set; }
		public List<VoiceCall> voice_calls { get; set; }
	}
	public class VoiceCall {
		public String engagement_id { get; set; }
		public String direction { get; set; }
		public List<String> call_legs { get; set; }
		public List<String> distributions { get; set; }
		public List<String> types { get; set; }
		public String caller_number { get; set; }
		public String caller_number_type { get; set; }
		public String callee_number { get; set; }
		public String callee_number_type { get; set; }
		public DateTime start_time { get; set; }
		public DateTime end_time { get; set; }
		public Integer total_duration { get; set; }
		public String consumer_number { get; set; }
		public String consumer_display_name { get; set; }
		public String country_name { get; set; }
		public Boolean recorded { get; set; }
		public Boolean monitored { get; set; }
		public Boolean inbox { get; set; }
		public String result { get; set; }
		public String caller_id { get; set; }
		public String calling_party { get; set; }
		public String charge { get; set; }
		public List<String> rates { get; set; }
		public String charge_type { get; set; }
		public List<QueueInfo> queues { get; set; }
		public List<AgentInfo> agents { get; set; }
		public List<FlowInfo> flows { get; set; }
	}

	public class QueueInfo {
		public String queue_id { get; set; }
		public String queue_name { get; set; }
	}

	public class AgentInfo {
		public String user_id { get; set; }
		public String display_name { get; set; }
	}

	public class FlowInfo {
		public String flow_id { get; set; }
		public String flow_name { get; set; }
	}
}