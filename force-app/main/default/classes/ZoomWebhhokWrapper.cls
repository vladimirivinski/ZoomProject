public with sharing class ZoomWebhhokWrapper {
	public cls_payload payload;
	public Integer event_ts;	//1672075959081
	public String event;	//endpoint.url_validation
	public class cls_payload {
		public String plainToken;	//6wAwT1b3SkS7tPR2wkoO1g
	}
	public static ZoomWebhhokWrapper parse(String json){
		return (ZoomWebhhokWrapper) System.JSON.deserialize(json, ZoomWebhhokWrapper.class);
	}

}