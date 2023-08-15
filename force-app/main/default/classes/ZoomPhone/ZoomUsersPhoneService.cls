public with sharing class ZoomUsersPhoneService {
    public static HttpResponse zoomPhoneCallsCallout(String email){
        String address = 'callout:ZoomPhone/phone/users/' + email + '/call_logs';
 
        // DateTime prev30Mins = DateTime.now().addMinutes(-30);
        DateTime lastHour = DateTime.now().addHours(-1);
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
        HttpResponse resopnse = http.send(req);
        return resopnse;
    }



    public static List<Zoom_Phone_Calls_Info__c> checkDuplicatePhoneCalls(Map<String, Zoom_Phone_Calls_Info__c> callMap){
        Map<String, Zoom_Phone_Calls_Info__c> orgCallsMap = new Map<String, Zoom_Phone_Calls_Info__c>();
        for (Zoom_Phone_Calls_Info__c calls : [SELECT z.Call_Id__c, z.id, Name, Call_Date_Time__c FROM Zoom_Phone_Calls_Info__c z WHERE CreatedDate = TODAY]) {
            orgCallsMap.put(calls.Call_Id__c, calls);
        }

        Map<String, Zoom_Phone_Calls_Info__c> resultMap = new Map<String, Zoom_Phone_Calls_Info__c>();
        for (String m : callMap.keySet()) {
            if (!orgCallsMap.containsKey(m)) resultMap.put(m, callMap.get(m));
        }

        List<Zoom_Phone_Calls_Info__c> resultCallsList = new List<Zoom_Phone_Calls_Info__c>();
        for (Zoom_Phone_Calls_Info__c i : resultMap.values()) {
            resultCallsList.add(i);
        }
        return resultCallsList;
    }
}