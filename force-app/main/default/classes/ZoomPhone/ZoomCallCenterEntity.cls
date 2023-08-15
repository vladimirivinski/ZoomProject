public with sharing class ZoomCallCenterEntity {

    public static CallsDataWrapper parse(String json){
        return (CallsDataWrapper) System.JSON.deserialize(json, CallsDataWrapper.class);
    }

    public class CallsDataWrapper {
		public String next_page_token { get; set; }
		public Integer page_size { get; set; }
		public Integer total_records { get; set; }
		public Datetime frm { get; set; }
		public Datetime to { get; set; }
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
		public Datetime start_time { get; set; }
		public Datetime end_time { get; set; }
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

// System.debug('engagement_id | ' + call.engagement_id);
// System.debug('direction | ' + call.direction);
// System.debug('call_legs | ' + call.call_legs);
// System.debug('distributions | ' + call.distributions);
// System.debug('types | ' + call.types);
// System.debug('caller_number | ' + call.caller_number);
// System.debug('caller_number_type | ' + call.caller_number_type);
// System.debug('callee_number | ' + call.callee_number);
// System.debug('callee_number_type | ' + call.callee_number_type);
// System.debug('start_time | ' + call.start_time);
// System.debug('end_time | ' + call.end_time);
// System.debug('total_duration | ' + call.total_duration);
// System.debug('consumer_number | ' + call.consumer_number);
// System.debug('consumer_display_name | ' + call.consumer_display_name);
// System.debug('country_name | ' + call.country_name);
// System.debug('recorded | ' + call.recorded);
// System.debug('monitored | ' + call.monitored);
// System.debug('inbox | ' + call.inbox);
// System.debug('result | ' + call.result);
// System.debug('caller_id | ' + call.caller_id);
// System.debug('calling_party | ' + call.calling_party);
// System.debug('charge | ' + call.charge);
// System.debug('rates | ' + call.rates);
// System.debug('charge_type | ' + call.charge_type);
// System.debug('agents.user_id | ' + call.agents.user_id);
// System.debug('agents.user_id | ' + call.agents.display_name);
// System.debug('queues.Id | ' + call.queues.queue_id);
// System.debug('queues.Name | ' + call.queues.queue_name);
// System.debug('++++++++++++++++++');