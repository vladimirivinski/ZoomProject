public without sharing class ZoomWebhookController {
    static final String PRESENCE_STATUS = 'user.presence_status_updated';
    static final String USER_SIGNED_IN = 'user.signed_in';
    static final String USER_SIGNED_OUT = 'user.signed_out';

    static final String CONTACT_CENTER_USER_LOGIN = 'contact_center.user_login';
    static final String CONTACT_CENTER_USER_LOGOUT = 'contact_center.user_logout';
    static final String CONTACT_CENTER_USER_STATUS_CHANGED = 'contact_center.user_status_changed';

    // Date used in SOQL get zoom user record crated today in PST format time
    static DateTime nowGMT = DateTime.now();
    static DateTime nowPST = nowGMT.addHours(-8);
    static final Date PST_DATE = Date.newInstance(nowPST.year(), nowPST.month(), nowPST.day());

    static String query = 'SELECT Id, Tracking_Date__c, Email__c, Presence_Status__c, Status_Updated__c, User_Log_In__c, User_Log_Out__c FROM Zoom_Users_Info__c';
    static String qWhere = ' WHERE Email__c = \'';
    static String qLimit = '\' AND Tracking_Date__c = :PST_DATE LIMIT 1';

    public static void checkZoomEvent(Map<String, Object> resp) {
        System.debug('resp====' + resp);
        String jsonString = JSON.serialize(resp);
        ResponseWrapper wrapper = populateWrapper(jsonString);
        System.debug('wrapper::::::::: ' + wrapper);

        String event = wrapper.event;
        String email = wrapper.payload.obj.email;
        String status = wrapper.payload.obj.presence_status;
        DateTime logTime = wrapper.payload.obj.date_time;


        if (event == PRESENCE_STATUS) {
            isPresenceStatusUpdated(email, status, logTime);
        } else if (event == USER_SIGNED_IN || event == USER_SIGNED_OUT) {
            isUserLogInOrOut(email, logTime, event);
        } else if (event == CONTACT_CENTER_USER_LOGIN) {

        } else if (event == CONTACT_CENTER_USER_LOGOUT) {

        } else if (event == CONTACT_CENTER_USER_STATUS_CHANGED) {

        } else {
            System.debug('Event not found');
        }

    }

    public static List<Zoom_Users_Info__c> getZoomUser(String email){
        List<Zoom_Users_Info__c> userList = !Test.isRunningTest() ?
            Database.query(query + qWhere + email + qLimit) :
            Database.query(query + qWhere + email + '\'');
        return userList;
    }

    public static void isPresenceStatusUpdated(String email, String status, DateTime logTime) {
        List<Zoom_Users_Info__c> userList = getZoomUser(email);
        if (userList.size() > 0 && !userList.isEmpty()) {
            userList[0].Presence_Status__c = status;
            userList[0].Status_Updated__c = logTime;
            update userList;
        }
    }

    public static void isUserLogInOrOut(String email, DateTime logTime, String event) {
        List<Zoom_Users_Info__c> userList = getZoomUser(email);
        try{
            for (Zoom_Users_Info__c u : userList) {
                if (userList.size() > 0 && (event == USER_SIGNED_IN)) {
                    userList[0].Presence_Status__c = 'Available';
                } else if (userList.size() > 0 && (event == USER_SIGNED_OUT)) {
                    userList[0].LogOut__c = logTime;
                    userList[0].Presence_Status__c = 'Offline';
                }
            }
            update userList;
        }
        catch (DmlException e) {
            System.debug('EXCEPTION: method ZoomWebhookController.isUserLogInOrOut: \n ' + e.getMessage());
        }
    }

    public static ResponseWrapper populateWrapper(String jsonString) {
        String jsonStr = jsonString.replace('"object":', '"obj":');
        ResponseWrapper wrapper = (ResponseWrapper) JSON.deserialize(jsonStr, ResponseWrapper.class);
        return wrapper;
    }

    public class ResponseWrapper {
        String event { get; set; }
        String event_ts { get; set; }
        PayloadWrapper payload { get; set; }
    }
    public class PayloadWrapper {
        String account_id { get; set; }
        ObjectWrapper obj { get; set; }
    }
    public class ObjectWrapper {
        String user_id { get; set; }
        String display_name { get; set; }
        String user_email { get; set; }
        String previous_status_id { get; set; }
        String previous_status_name { get; set; }
        String previous_sub_status_id { get; set; }
        String previous_sub_status_name { get; set; }
        String current_status_id { get; set; }
        String current_status_name { get; set; }
        String current_sub_status_id { get; set; }
        String current_sub_status_name { get; set; }
        DateTime date_time { get; set; }
        String presence_status { get; set; }
        String email { get; set; }
        String id { get; set; }
    }

}

// {
//     event=user.presence_status_updated, 
//     event_ts=1691535992008, 
//     payload=
//         {
//         account_id=kJdQOXj6TXeWcSfh_ysPVQ, 
//         object=
//             {
//                 date_time=2023-08-08T23:06:32Z,
//                 email=dpatel@myubiquity.com,
//                 id=uzybhvofrtedy8bjbf-eyq,
//                 presence_status=Offline
//             }
//         }
// }


// {
//   "event": "contact_center.user_status_changed",
//   "event_ts": 1627906944384,
//   "payload": {
//     "account_id": "D8cJuqWVQ623CI4Q8yQK0Q",
//     "object": {
//       "user_id": "ukAAkZKfROKMSw1bj_RDFQ",
//       "display_name": "Jill Chill",
//       "user_email": "jchill@example.com",
//       "previous_status_id": "2",
//       "previous_status_name": "Not Ready",
//       "previous_sub_status_id": "20",
//       "previous_sub_status_name": "Break",
//       "current_status_id": "2",
//       "current_status_name": "Not Ready",
//       "current_sub_status_id": "21",
//       "current_sub_status_name": "Meal",
//       "date_time": "2022-02-15T09:27:15Z"
//     }
//   }
// }

// {
//   "event": "contact_center.user_login",
//   "event_ts": 1627906944384,
//   "payload": {
//     "account_id": "D8cJuqWVQ623CI4Q8yQK0Q",
//     "object": {
//       "user_id": "ukAAkZKfROKMSw1bj_RDFQ",
//       "display_name": "Jill Chill",
//       "user_email": "jchill@example.com",
//       "date_time": "2022-02-15T09:27:15Z"
//     }
//   }
// }



