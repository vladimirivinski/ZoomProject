public with sharing class ZoomUsersPhoneInfosBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, schedulable {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, Email__c FROM Zoom_Users_Info__c WHERE CreatedDate = TODAY';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Zoom_Users_Info__c> scope) {       
        List<Zoom_Phone_Calls_Info__c> callLst = new List<Zoom_Phone_Calls_Info__c>();
        Map<String, Zoom_Phone_Calls_Info__c> callMap = new Map<String, Zoom_Phone_Calls_Info__c>();
        Map<String, Zoom_Phone_Calls_Info__c> orgCallsMap  = new Map<String, Zoom_Phone_Calls_Info__c >();
        Map<String, Zoom_Phone_Calls_Info__c> resultMap = new Map<String, Zoom_Phone_Calls_Info__c>();
        
        List<Zoom_Phone_Calls_Info__c> result = new List<Zoom_Phone_Calls_Info__c>();

        for (Zoom_Users_Info__c usr : scope ){
            String address = 'callout:ZoomPhone/phone/users/'+usr.Email__c+'/call_logs';
            
            DateTime now = DateTime.now();
            DateTime prevHour = now.addHours(-1);
            // DateTime prev10Mins = now.addMinutes(-20);
            String fromStr = prevHour.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
            String toStr = now.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
            String fromTime = '?from=' + fromStr;
            String toTime = '&to=' + toStr ;
            
            String pageSize = '&page_size=300';
            String url = address + fromTime + toTime + pageSize;

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Content-type', 'application/json');
            req.setEndpoint(url); 
            Http http = new Http();
            HttpResponse res = http.send(req);
            // System.debug(' \n ^^^^^^^^^^^^^^^^^^^^ RESPONSE BODY ^^^^^^^^^^^^^^^^^^^^ \n' + res.getBody());
            if (res.getStatusCode() == 200) {
                try{
                    ZooomUserResponseWrapper wrappedResponse = ZooomUserResponseWrapper.parse(res.getBody());
                    if(wrappedResponse.total_records != null && wrappedResponse.total_records != 0){
                        for(ZooomUserResponseWrapper.cls_call_logs val : wrappedResponse.call_logs){
                            System.debug('--------------- val -------------- : ' + val);
                            Zoom_Phone_Calls_Info__c info = new Zoom_Phone_Calls_Info__c();
                            info.Name = usr.name;
                            info.Zoom_Users_Info__c = usr.id;
                            info.Email__c = usr.email__c;
                            info.Call_Date_Time__c = val.date_time;
                            info.Call_Id__c = val.call_id;
                            info.caller_name__c = val.caller_name;
                            info.caller_number__c = val.caller_number;
                            info.Call_Result__c = val.result;
                            info.has_recording__c = val.recording_type != null ? true : false;
                            info.recording_Id__c = val.recording_id != null ? val.recording_id : null;
                            if(val.direction == 'inbound'){
                                info.Inbound_Call__c = val.direction;
                                info.Inbound_Call_Duration__c = val.duration; // CHECK !!!!
                                info.Waiting_Time__c = val.waiting_time; // ??CHECK
                                info.Hold_Time__c = val.hold_time; // ??CHECK
                            } else if(val.direction == 'outbound'){
                                info.Outbound_Call__c = val.direction;
                                info.Outbound_Call_Duration__c = val.duration;
                            }
                            callMap.put(info.Call_Id__c, info);
                        }
                }
                }  catch(Exception e) {
                    System.debug('Wrapper Exception may occurred ' +e.getMessage());
                }
            }
        }
        
        // for(Zoom_Phone_Calls_Info__c calls :[SELECT z.Call_Id__c, z.id, Name, Call_Date_Time__c FROM Zoom_Phone_Calls_Info__c z WHERE Call_Date_Time__c = TODAY]){ 
        for(Zoom_Phone_Calls_Info__c calls :[SELECT z.Call_Id__c, z.id, Name, Call_Date_Time__c FROM Zoom_Phone_Calls_Info__c z WHERE CreatedDate = TODAY]){ 
            orgCallsMap.put(calls.Call_Id__c, calls);
        }
        // //TODO: Create handler  and converter
        // Compare Maps with org data and inbound data
        for(String m: callMap.keySet()){
            if(!orgCallsMap.containsKey(m)){
                resultMap.put(m, callMap.get(m));
            }
        }
        // Convert to result list for insert
        for(Zoom_Phone_Calls_Info__c i: resultMap.values()){
            callLst.add(i);
        }
        insert callLst;
    } 
    public void finish(Database.BatchableContext BC){}


    public static void start(Integer mins){
        string jobName = 'Zoom Phone Calls updater job';
        if (mins == 007) Database.executeBatch(new ZoomUsersPhoneInfosBatch(), 50);
        else{
            jobName = jobName += mins + ' - ' + datetime.now().format();
            System.schedule(jobName, '0 '+ string.valueof(mins) + ' * * * ?', new ZoomUsersPhoneInfosBatch());
        }
    }
    public void execute(SchedulableContext SC) {
        database.executeBatch(new ZoomUsersPhoneInfosBatch(), 50);
    }
}


//Start all batches every 10 minutes
// ZoomUsersPhoneInfosBatch.start(0);
// ZoomUsersPhoneInfosBatch.start(10);
// ZoomUsersPhoneInfosBatch.start(20);
// ZoomUsersPhoneInfosBatch.start(30);
// ZoomUsersPhoneInfosBatch.start(40);
// ZoomUsersPhoneInfosBatch.start(50);

//Id batchJobId = Database.executeBatch(new ZoomUsersPhoneInfosBatch(), 10);

    // static DateTime nowGMT = DateTime.now();
    // static DateTime nowPST = nowGMT.addHours(-8);
    // static final Date PST_DATE = Date.newInstance(nowPST.year(), nowPST.month(), nowPST.day());