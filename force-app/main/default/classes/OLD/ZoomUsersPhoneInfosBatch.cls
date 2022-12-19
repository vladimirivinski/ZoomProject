global with sharing class ZoomUsersPhoneInfosBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static final String NOW = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    public static final String LAST_30MIN = DateTime.now().addMinutes(-30).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    public static final Datetime LAST_30MINs = DateTime.now().addMinutes(-30);
    
    public String query = 'SELECT Id, Name, Email__c, Inbound_Calls__c, Outbound_Calls__c  FROM Zoom_Users_Info__c WHERE Tracking_Date__c = TODAY';
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Zoom_Users_Info__c> scope) {       
        List<Zoom_Phone_Calls_Info__c> callLst = new List<Zoom_Phone_Calls_Info__c>();
        Map<String, Zoom_Phone_Calls_Info__c> callMap = new Map<String, Zoom_Phone_Calls_Info__c>();
        Map<String, Zoom_Phone_Calls_Info__c> orgCallsMap  = new Map<String, Zoom_Phone_Calls_Info__c >();
        Map<String, Zoom_Phone_Calls_Info__c> resultMap = new Map<String, Zoom_Phone_Calls_Info__c>();

        for(Zoom_Phone_Calls_Info__c calls :[SELECT z.Call_Id__c, z.id, Name, CreatedDate,Call_Date_Time__c 
                                                FROM Zoom_Phone_Calls_Info__c z 
                                                WHERE CreatedDate = TODAY
                                            ]){ // CHECK > VARIABLE!!!!!!!!!!!!!! WHERE CreatedDate > :LAST_30MINs
            orgCallsMap.put(calls.Call_Id__c, calls);
        }
        for (Zoom_Users_Info__c usr : scope ){
            String endpoint = 'callout:ZoomPhone/phone/users/'+usr.email__c+'/call_logs';
            // String address = 'callout:ZoomPhone/phone/users/'+usr.email__c+'/call_logs';
            // String address = 'https://api.zoom.us/v2/ZoomPhone/phone/users/'+usr.email__c+'/call_logs';
            // String fromTime = '?from=' + '"' + LAST_30MIN + '"';
            // String toTime = '&to='  + '"' + NOW + '"';
            // // String pageSize = '&page_size=300';
            // String  = address + fromTime + toTime;

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Content-type', 'application/json');
            req.setEndpoint(endpoint); 
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                try{
                    ZooomUserResponseWrapper wrappedResponse = ZooomUserResponseWrapper.parse(res.getBody());
                    Integer inbound = 0;
                    Integer outbound = 0;
                    if(wrappedResponse.total_records != null && wrappedResponse.total_records != 0){
                        for(ZooomUserResponseWrapper.cls_call_logs val : wrappedResponse.call_logs){
                            Zoom_Phone_Calls_Info__c info = new Zoom_Phone_Calls_Info__c();
                            info.Name = usr.name;
                            info.Zoom_Users_Info__c = usr.id;
                            info.Email__c = usr.email__c;
                            info.Call_Date_Time__c = val.date_time;
                            info.Call_Id__c = val.call_id;
                            if(val.direction == 'inbound'){
                                inbound++;
                                info.Inbound_Call__c = val.direction;
                                info.Inbound_Call_Duration__c = val.duration/60; // CHECK !!!!
                                info.Waiting_Time__c = val.waiting_time; // ??CHECK
                                info.Hold_Time__c = val.hold_time; // ??CHECK
                            } else if(val.direction == 'outbound'){
                                outbound++;
                                info.Outbound_Call__c = val.direction;
                                info.Outbound_Call_Duration__c = val.duration;
                            }
                            // callLst.add(info);
                            callMap.put(info.Call_Id__c, info);
                            usr.Inbound_Calls__c = inbound;
                            usr.Outbound_Calls__c = outbound;
                        }
                }
                }  catch(Exception e) {
                    System.debug('Wrapper Exception may occurred ' +e.getMessage());
                }
            }
        }
        update scope;

        // //TODO: Create handler  and converter
        // Compare Maps with org data and inbound data
        for(String m: callMap.keySet()){
            if(!orgCallsMap.containsKey(m))
                resultMap.put(m, callMap.get(m));
        }
        // Convert to result list for insert
        for(Zoom_Phone_Calls_Info__c i: resultMap.values()){
            callLst.add(i);
        }
        insert callLst;
    } 
    global void finish(Database.BatchableContext BC){}
}

//Id batchJobId = Database.executeBatch(new ZoomUsersPhoneInfosBatch(), 10);

        // DateTime dt = DateTime.now();
        // String nowStr = String.valueOf(dt);
        // List<String> nowLst = nowStr.split(' ');
        // String now = String.join(nowLst,'\'T\'') + '\'Z\'';
        
        // DateTime dt15 = DateTime.now().addMinutes(-15);
        // String lstStr = String.valueOf(dt15);
        // List<String> lstStr15 = lstStr.split(' ');
        // String last15Min = String.join(lstStr15,'\'T\'') + '\'Z\'';