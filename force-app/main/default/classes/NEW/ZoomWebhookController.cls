public without sharing class ZoomWebhookController {
    static final String PRESENCE_STATUS = 'user.presence_status_updated';
    static final String USER_SIGNED_IN = 'user.signed_in';
    static final String USER_SIGNED_OUT = 'user.signed_out';
    static String query = 'SELECT Id, Tracking_Date__c, Email__c, Presence_Status__c, Status_Updated__c, LogIn__c, LogOut__c, User_Log_In__c, User_Log_Out__c FROM Zoom_Users_Info__c';
    static String qWhere = ' WHERE Email__c = \'';
    static String qLimit = '\' AND Tracking_Date__c = TODAY LIMIT 1';

    public static void checkZoomEvent(Map<String,Object> resp){
        // TODO: Create wrapper class
        // =================================================================================================
        // =================================================================================================
        Map<String,Object> mPayload = (Map<String,Object>)resp.get('payload');
        Map<String,Object> mObj = (Map<String,Object>)mPayload.get('object');
        String zoomEvent  = resp.get('event').toString();
        String accId = mPayload.get('account_id').toString();
        String email = mObj.get('email').toString();
        DateTime logTime = (DateTime)JSON.deserialize('"'+mObj.get('date_time')+'"', DateTime.class);
        // =================================================================================================
        // =================================================================================================
        
        if(zoomEvent == PRESENCE_STATUS){
            String status = mObj.get('presence_status').toString();
            isPresenceStatusUpdated(email, status, zoomEvent, logTime);
        } else if(zoomEvent == USER_SIGNED_IN || zoomEvent == USER_SIGNED_OUT ){
            isUserLogInOrOut(email, logTime, zoomEvent);
        }
    }

    public static void isPresenceStatusUpdated(String email, String status, String event, DateTime logTime){
        List<Zoom_Users_Info__c> usr = Database.query(query+qWhere+email+qLimit);
        if(usr.size()>0 && !usr.isEmpty()){
            usr[0].Presence_Status__c = status;
            usr[0].Status_Updated__c = logTime;
            update usr;
        }
    }

    // TODO: refactore class
    public static void isUserLogInOrOut(String email, DateTime logTime, String event){
        List<Zoom_Users_Info__c> usr = Database.query(query+qWhere+email+qLimit);
        for(Zoom_Users_Info__c u: usr){
            if(usr.size()>0 && (event == USER_SIGNED_IN || event == USER_SIGNED_OUT)){
                createUserEventInfo(event, logTime, USER_SIGNED_IN, usr);
            } 
        }
    }

    public static void createUserEventInfo(String event, DateTime logTime, String status, List<Zoom_Users_Info__c> usr){
        Zoom_Event_Info__c eventInfo = new Zoom_Event_Info__c();
        eventInfo.Zoom_Users_Info__c = usr[0].id;
        eventInfo.name = status;
        eventInfo.Email__c = usr[0].Email__c;
        if(event == USER_SIGNED_IN){
            eventInfo.Log_in__c = logTime;
            usr[0].Presence_Status__c = 'Available';
            update usr; 
        } 
        if(event == USER_SIGNED_OUT){
            eventInfo.Log_Out__c = logTime;
            usr[0].LogOut__c = logTime;
            usr[0].Presence_Status__c = 'Offline';
            update usr;
        }
        if(event == PRESENCE_STATUS){
            eventInfo.Presence_status__c = status;
            eventInfo.Presence_status_time__c = logTime;
        }  
        try {
            insert eventInfo;
        } catch (DmlException e) {
            System.debug('EXCEPTION: method createUserEventInfo: \n ' + e.getMessage());
        }
    }
}
