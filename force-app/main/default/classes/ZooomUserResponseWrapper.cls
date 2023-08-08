public with sharing class ZooomUserResponseWrapper {
	public String next_page_token;	//
	public Integer page_size;	//30
	public Integer total_records;	//7
	public String frm;	//2022-12-10
	public String to;	//2022-12-11
	public List<cls_call_logs> call_logs;
	public class cls_call_logs {
		public String id;	//1239d685-902c-414f-9676-3b53cebccde6
		public String call_type;	//pstn
		public String caller_number;	//3787 +
		public Integer caller_number_type;	//1
		public String caller_name;	//Jay Jacob +
		public String callee_number;	//+13109410034 !
		public String callee_name; // ?
		public Integer callee_number_type;	//2
		public String callee_number_source;	//internal !
		public String calleer_number_source; // ?
		public String callee_location;	//California !
		public String direction;	//outbound
		public Integer duration;	//38
		public String result;	//Call connected
		public DateTime date_time;	//2022-12-10T00:43:05Z
		public Integer waiting_time; // 17
		public Integer hold_time; // 5
		public boolean has_recording;
		public boolean has_voicemail;
		public String call_id;	//7175314034216187889
		public String caller_did_number;	//+14157663787
		public String caller_country_code;	//1
		public String caller_country_iso_code;	//US
		public String callee_did_number;	//+13109410034
		public String callee_country_code;	//1
		public String callee_country_iso_code;	//US
		public DateTime call_end_time;	//2022-12-10T00:43:50Z
		public String department;	//
		public String cost_center;	//
		public String recording_type;
		public cls_forwarded_by forwarded_by;
		public String recording_id;
	}
	class cls_forwarded_by {
		public String name;	//CE Employer Q
		public String extension_type;	//callQueue
		public String extension_number;	//5170
	}
	public static ZooomUserResponseWrapper parse(String json){
		return (ZooomUserResponseWrapper) System.JSON.deserialize(json, ZooomUserResponseWrapper.class);
	}
}