global with sharing class ZoomUsersPhoneInfosBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, schedulable {
    // Date used in SOQL get all zoom users records crated today in PST format time
    static DateTime nowGMT = DateTime.now();
    static DateTime nowPST = nowGMT.addHours(-8);
    static final Date PST_DATE = Date.newInstance(nowPST.year(), nowPST.month(), nowPST.day());

    public String query = 'SELECT Id, Name, Email__c FROM Zoom_Users_Info__c WHERE Tracking_Date__c = :PST_DATE';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Zoom_Users_Info__c> scope) {       
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
            System.debug(' \n ^^^^^^^^^^^^^^^^^^^^ RESPONSE BODY ^^^^^^^^^^^^^^^^^^^^ \n' + res.getBody());
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
                            // result: Auto Recorded || Call connected || Busy || No Answer || Answered by Other Member || Rejected
                            // recording_type: null || Automatic ~ On-demand
                            // has_recording : false || null - deprecated
                            info.Call_Result__c = val.result;
                            info.has_recording__c = val.recording_type != null ? true : false;
                            if(val.direction == 'inbound'){
                                info.Inbound_Call__c = val.direction;
                                info.Inbound_Call_Duration__c = val.duration/60; // CHECK !!!!
                                info.Waiting_Time__c = val.waiting_time; // ??CHECK
                                info.Hold_Time__c = val.hold_time; // ??CHECK
                            } else if(val.direction == 'outbound'){
                                info.Outbound_Call__c = val.direction;
                                info.Outbound_Call_Duration__c = val.duration/60;
                            }
                            // result.add(info);
                            callMap.put(info.Call_Id__c, info);
                        }
                }
                }  catch(Exception e) {
                    System.debug('Wrapper Exception may occurred ' +e.getMessage());
                }
            }
        }
        // insert result;
        
        for(Zoom_Phone_Calls_Info__c calls :[SELECT z.Call_Id__c, z.id, Name, Call_Date_Time__c FROM Zoom_Phone_Calls_Info__c z WHERE Call_Date_Time__c = TODAY]){ 
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
    global void finish(Database.BatchableContext BC){}


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

        // DateTime dt = DateTime.now();
        // String nowStr = String.valueOf(dt);
        // List<String> nowLst = nowStr.split(' ');
        // String now = String.join(nowLst,'\'T\'') + '\'Z\'';
        
        // DateTime dt15 = DateTime.now().addMinutes(-15);
        // String lstStr = String.valueOf(dt15);
        // List<String> lstStr15 = lstStr.split(' ');
        // String last15Min = String.join(lstStr15,'\'T\'') + '\'Z\'';


// public static final String NOW = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
// public static final String LAST_30MIN = DateTime.now().addMinutes(-30).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
// public static final Datetime LAST_30MINs = DateTime.now().addMinutes(-30);

// String address = 'callout:ZoomPhone/phone/users/'+usr.email__c+'/call_logs';
// String fromTime = '?from=' + LAST_30MIN;
// String toTime = '&to=' + NOW ;
// String pageSize = '&page_size=300';
// String params = fromTime + toTime + pageSize;




// global static String toUrlParams(Map<String,String> params){
//     List<String> paramsList = new List<String>();
//     for(String k :params.keySet()){
//         string val=params.get(k);
//         paramsList.add(k + '=' + (val!=null?EncodingUtil.URLENCODE(params.get(k),'UTF-8'):''));
//     }
//     return String.join(paramsList, '&');
// }

// global static String getEndpoint(String endpoint, Map<String, String> urlParams){
//     if(urlParams != NULL && !urlParams.isEmpty()){
//         endpoint = endpoint + '?' + toUrlParams(urlParams);
//     }
//     return endpoint;
// }

// Map<String, String> params = new Map<String, String>{
//     'from' => LAST_30MIN,
//     'to' => NOW,
//     'page_size' => '300'
// };


// =============================================================================================

            // String dt = String.valueOf(Date.today());
            // String fromTime = '?from=' + dt;
            // String toTime = '&to=' + dt ;
            // String pageSize = '&page_size=300';
            // String url = address + fromTime + toTime + pageSize;
         
            // String pageSize = '?page_size=300';
            // String url = address + pageSize;

    // Date now = Date.today(); //2023-01-05 00:00:00
            // DateTime startTime = Datetime.newInstance(now.year(), now.month(), now.day(), 8, 0, 0);
            // String strConvertedDateGMT = startTime.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
            // DateTime currTime = DateTime.now();
            // String endTime = currTime.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');

            // DateTime endTime0 = Datetime.newInstance(now.year(), now.month(), now.day(), 0, 0, 0);
            // DateTime endTime8 = Datetime.newInstance(now.year(), now.month(), now.day(), 8, 0, 0);
            // DateTime endTime15 = Datetime.newInstance(now.year(), now.month(), now.day(), 15, 0, 0);
            // String endConvertedDateGMT = endTime15.format('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
            

            // System.debug(' \n =-=-=-=-=-=-=-=-= now -=-=-=-=-=-=-=-=-= \n ' + now);                                 //  2023-01-05 00:00:00
            // System.debug(' \n =-=-=-=-=-=-=-=-= startTime -=-=-=-=-=-=-=-=-= \n ' + startTime);                     //  2023-01-05 08:00:00
            // System.debug(' \n =-=-=-=-=-=-=-=-= strConvertedDateGMT -=-=-=-=-=-=-=-=-= \n ' + strConvertedDateGMT); //  2023-01-05T00:00:00Z !!!
            // System.debug(' \n =-=-=-=-=-=-=-=-= endTime0 -=-=-=-=-=-=-=-=-= \n ' + endTime0);                       //  2023-01-05 08:00:00
            // System.debug(' \n =-=-=-=-=-=-=-=-= endTime8 -=-=-=-=-=-=-=-=-= \n ' + endTime8);                       //  2023-01-05 16:00:00
            // System.debug(' \n =-=-=-=-=-=-=-=-= endTime15 -=-=-=-=-=-=-=-=-= \n ' + endTime15);                     //  2023-01-05 23:00:00
            // System.debug(' \n =-=-=-=-=-=-=-=-= endConvertedDateGMT -=-=-=-=-=-=-=-=-= \n ' + endConvertedDateGMT); //  2023-01-05T15:00:00Z !!!

            // =================================================================