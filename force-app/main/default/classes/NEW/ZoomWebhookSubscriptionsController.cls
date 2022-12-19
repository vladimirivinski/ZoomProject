public without sharing class ZoomWebhookSubscriptionsController {
    static final String PRESENCE_STATUS = 'user.presence_status_updated';
    static final String USER_SIGNED_IN = 'user.signed_in';
    static final String USER_SIGNED_OUT = 'user.signed_out';
    static String query = 'SELECT Id, Tracking_Date__c, Email__c, Presence_Status__c, User_Log_In__c, User_Log_Out__c FROM Zoom_Users_Info__c';
    static String qWhere = ' WHERE Email__c = \'';
    static String qLimit = '\' AND Tracking_Date__c = TODAY LIMIT 1';

    public static void checkZoomEvent(Map<String,Object> resp){
        // TODO: Create wrapper class
        Map<String,Object> mPayload = (Map<String,Object>)resp.get('payload');
        Map<String,Object> mObj = (Map<String,Object>)mPayload.get('object');
        String zoomEvent  = resp.get('event').toString();
        String accId = mPayload.get('account_id').toString();
        String email = mObj.get('email').toString();
        DateTime logTime = (DateTime)JSON.deserialize('"'+mObj.get('date_time')+'"', DateTime.class);

        if(zoomEvent == PRESENCE_STATUS){
            String status = mObj.get('presence_status').toString();
            isPresenceStatusUpdated(email, status, zoomEvent, logTime);
        } else if(zoomEvent == USER_SIGNED_IN || zoomEvent == USER_SIGNED_OUT ){
            isUserLogInOrOut(email, logTime, zoomEvent);
        }
    }

    public static void isPresenceStatusUpdated(String email, String status, String event, DateTime logTime){
        List<Zoom_Users_Info__c> usrLst = Database.query(query+qWhere+email+qLimit);
        try {
            if(usrLst.size()>0 && !usrLst.isEmpty()){
                usrLst[0].Presence_Status__c = status;
                createUserEventInfo(event, logTime, status, usrLst);
                update usrLst;
            }
        } catch (DmlException e) {
            System.debug('EXCEPTION: method isPresenceStatusUppdated: \n' + e.getMessage());
        }
    }

    // TODO: refactore class
    public static void isUserLogInOrOut(String email, DateTime logTime, String event){
        List<Zoom_Users_Info__c> usrLst = Database.query(query+qWhere+email+qLimit);
        for(Zoom_Users_Info__c u: usrLst){
            if(usrLst.size()>0 && (event == USER_SIGNED_IN || event == USER_SIGNED_OUT)){
                createUserEventInfo(event, logTime, USER_SIGNED_IN, usrLst);
            } 
        }
    }

    public static void createUserEventInfo(String event, DateTime logTime, String status, List<Zoom_Users_Info__c> usrLst){
        Zoom_Event_Info__c rec = new Zoom_Event_Info__c();
        rec.Zoom_Users_Info__c = usrLst[0].id;
        rec.name = status;
        rec.Email__c = usrLst[0].Email__c;
        if(event == USER_SIGNED_IN){
            rec.Log_in__c = logTime;
        } 
        if(event == USER_SIGNED_OUT || event == 'Offline'){
            rec.Log_Out__c = logTime;
            usrLst[0].LogOut__c = logTime;
            update usrLst;
        }
        if(event == PRESENCE_STATUS){
            if(event == 'Offline'){ // Get LogOut State from last Offline event
                usrLst[0].LogOut__c = logTime;
                update usrLst; 
            }
            rec.Presence_status__c = status;
            rec.Presence_status_time__c = logTime;
        }  
        try {
            insert rec;
        } catch (DmlException e) {
            System.debug('EXCEPTION: method createUserEventInfo: \n ' + e.getMessage());
        }
    }
}
// {"event":"user.presence_status_updated",
// "payload":{"account_id":"kJdQOXj6TXeWcSfh_ysPVQ","object":{"date_time":"2022-12-05T23:01:43Z",  "email":"ckoshkin@myubiquity.com","id":"9tjm_dgtrhofhm3iccw1ma","presence_status":"Offline"}},"event_ts":1670281303146}


