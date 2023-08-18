public with sharing class ZoomUsersPhoneService {
	public static List<Zoom_Phone_Calls_Info__c> getPhoneCalls(String email, Zoom_Users_Info__c usr) {
		List<Zoom_Phone_Calls_Info__c> resultCallsList = new List<Zoom_Phone_Calls_Info__c>();
		HttpResponse response = zoomPhoneCallsCallout(email);
		if (response.getStatusCode() == 200) {
			resultCallsList = createZoomPhoneCalls(response.getBody(), usr);
		}
		return resultCallsList;
	}

	public static HttpResponse zoomPhoneCallsCallout(String email) {
		String address = 'callout:ZoomPhone/phone/users/' + email + '/call_logs';
		DateTime lastHour = DateTime.now().addHours(-2);
		String fromStr = lastHour.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
		String toStr = DateTime.now().formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
		String fromTime = '?from=' + fromStr;
		String toTime = '&to=' + toStr;

		String pageSize = '&page_size=300';
		String url = address + fromTime + toTime + pageSize;

		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Content-type', 'application/json');
		req.setEndpoint(url);
		Http http = new Http();
		HttpResponse response = http.send(req);
		return response;
	}

	public static List<Zoom_Phone_Calls_Info__c> createZoomPhoneCalls(String resBody, Zoom_Users_Info__c usr) {
		Id recordTypeId = Schema.SObjectType.Zoom_Phone_Calls_Info__c.getRecordTypeInfosByName().get('Phone Users').getRecordTypeId();
		Map<String, Zoom_Phone_Calls_Info__c> callsIdZoomInfoMap = new Map<String, Zoom_Phone_Calls_Info__c>();

		ZoomUsersPhoneEntity wrappedResponse = ZoomUsersPhoneEntity.parse(resBody);
		if (wrappedResponse.total_records != null && wrappedResponse.total_records != 0) {
			for (ZoomUsersPhoneEntity.cls_call_logs val : wrappedResponse.call_logs) {
				Zoom_Phone_Calls_Info__c info = new Zoom_Phone_Calls_Info__c();
				info.Name = usr.name;
				info.Zoom_Users_Info__c = usr.id;
				info.Email__c = usr.email__c;
				info.RecordTypeId = recordTypeId;

				info.Call_Date_Time__c = val.date_time;
				info.Call_Id__c = val.call_id;
				info.caller_name__c = val.caller_name;
				info.caller_number__c = val.caller_number;
				info.Caller_Number_Source__c = val.calleer_number_source;
				info.Callee_Number_Source__c = val.callee_number_source;
				info.Callee_Name__c = val.callee_number_source;
				info.Callee_Number__c = val.callee_number;
				info.Callee_Location__c = val.callee_location;
				info.Call_Result__c = val.result;
				info.has_recording__c = val.recording_type != null ? true : false;
				info.recording_Id__c = val.recording_id != null ? val.recording_id : null;
				info.Call_Direction__c = val.direction;
				info.Duration__c = val.duration;

				// Refactor this part
				// Calculate the duration of the calls in Zoom Users Info object
				// in formula fields
				if (val.direction == 'inbound') {
					info.Inbound_Call__c = val.direction;
					info.Inbound_Call_Duration__c = val.duration;
					info.Waiting_Time__c = val.waiting_time;
					info.Hold_Time__c = val.hold_time;
				} else if (val.direction == 'outbound') {
					info.Outbound_Call__c = val.direction;
					info.Outbound_Call_Duration__c = val.duration;
				}
				callsIdZoomInfoMap.put(info.Call_Id__c, info);
			}
		}
		List<Zoom_Phone_Calls_Info__c> resultCallsList = checkDuplicatePhoneCalls(callsIdZoomInfoMap);
		return resultCallsList;
	}

	public static List<Zoom_Phone_Calls_Info__c> checkDuplicatePhoneCalls(Map<String, Zoom_Phone_Calls_Info__c> callMap) {
		Map<String, Zoom_Phone_Calls_Info__c> orgCallsMap = new Map<String, Zoom_Phone_Calls_Info__c>();
		for (Zoom_Phone_Calls_Info__c calls : [
			SELECT z.Call_Id__c, z.id, Name, Call_Date_Time__c
			FROM Zoom_Phone_Calls_Info__c z
			WHERE CreatedDate = TODAY
		]) {
			orgCallsMap.put(calls.Call_Id__c, calls);
		}

		Map<String, Zoom_Phone_Calls_Info__c> resultMap = new Map<String, Zoom_Phone_Calls_Info__c>();
		for (String m : callMap.keySet()) {
			if (!orgCallsMap.containsKey(m))
				resultMap.put(m, callMap.get(m));
		}

		List<Zoom_Phone_Calls_Info__c> resultCallsList = new List<Zoom_Phone_Calls_Info__c>();
		for (Zoom_Phone_Calls_Info__c i : resultMap.values()) {
			resultCallsList.add(i);
		}
		return resultCallsList;
	}
}
