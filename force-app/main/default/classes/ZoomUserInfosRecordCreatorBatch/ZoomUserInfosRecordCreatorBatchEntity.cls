public with sharing class ZoomUserInfosRecordCreatorBatchEntity {

    public static ZoomUsersResponseWrapper parse(String json){
        json.replace('"number":', '"phone":');
		return (ZoomUsersResponseWrapper) System.JSON.deserialize(json, ZoomUsersResponseWrapper.class);
	}

    public class ZoomUsersResponseWrapper {
        public String next_page_token { get; set; }
        public Integer page_size { get; set; }
        public Integer total_records { get; set; }
        public List<ZoomUsersProfileWrapper> users { get; set; }
    }
    public class ZoomUsersProfileWrapper {
        public String email { get; set; }
        public String extension_id { get; set; }
        public Integer extension_number { get; set; }
        public String id { get; set; }
        public String name { get; set; }
        public String phone_user_id { get; set; }
        public String status { get; set; }
        public String department { get; set; }
        public String cost_center { get; set; }
        public cls_site site { get; set; }
        public List<CallingPlans> calling_plans { get; set; }
        public List<PhoneNumbers> phone_numbers { get; set; }
    }

    public class CallingPlans {
        public String name { get; set; }
        public Integer type { get; set; }
        public String billing_account_id { get; set; }
        public String billing_account_name { get; set; }
    }

    public class cls_site {
        public String id { get; set; }
        public String name { get; set; }
    }

    public class PhoneNumbers {
        public String id { get; set; }
        public String phone { get; set; }
    }
}