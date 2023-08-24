@isTest
public class ZoomWebhookControllerTest {

    @TestSetup
    static void makeData(){
        CallCenter cc =[SELECT Id FROM CallCenter LIMIT 1];
        Profile profId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = new User();
        usr.Email                           = 'testzoommail23@mail.com';
        usr.Username                        = 'testzoommail23@mail.com';
        usr.FirstName                       = 'Test';
        usr.LastName                        = 'User';
        usr.Alias                           = 'tuser';
        usr.TimeZoneSidKey                  = 'America/Los_Angeles';
        usr.LocaleSidKey                    = 'en_US';
        usr.EmailEncodingKey                = 'UTF-8';
        usr.LanguageLocaleKey               = 'en_US';
        usr.isActive                        = true;
        usr.ProfileId                       = profId.Id;
        usr.CallCenterId                    = cc.Id;
        insert usr;

        User createdUser = [SELECT Id, Email, Name FROM User WHERE Username = 'testzoommail23@mail.com' LIMIT 1];

        Zoom_Users_Info__c zoomUser = new Zoom_Users_Info__c();
        zoomUser.User__c                    = createdUser.Id;
        zoomUser.Email__c                   = createdUser.Email;
        zoomUser.Name                       = createdUser.Name;
        zoomUser.Presence_Status__c         = 'Away';
        zoomUser.Status_Updated__c          = DateTime.now();
        zoomUser.Tracking_Date__c           = Date.today();
        zoomUser.Available__c               = 0;
        zoomUser.Away__c                    = 0;
        zoomUser.In_Calendar_Event__c       = 0;
        zoomUser.In_Meeting__c              = 0;
        zoomUser.Offline__c                 = 0;
        zoomUser.On_Phone_Call__c           = 0;
        zoomUser.Presenting__c              = 0;
        zoomUser.Do_Not_Disturb__c          = 0;
        zoomUser.Zoom_User_Id__c            = 'kJdQOXj6TXeWcSfh_ysPVQ';
        zoomUser.Contact_Center_Status__c   = 'Ready';
        zoomUser.CC_Prev_Status__c          = 'Occupied';
        zoomUser.CC_Status_Updated__c       = DateTime.Now();
        zoomUser.Ready__c                   = 0;
        zoomUser.Not_Ready__c               = 0;
        zoomUser.Occupied__c                = 0;
        zoomUser.Offline_Status__c          = 0;
        insert zoomUser;
}

    @isTest
    public static void checkZoomEventTest(){
        String statusBody = '{"event":"user.presence_status_updated","payload":{"account_id":"kJdQOXj6TXeWcSfh_ysPVQ","object":{"date_time":"2023-01-24T14:47:36Z","email":"testzoommail23@mail.com","id":"p3x1bwrmsh6tnl_bxyrlca","presence_status":"On_Phone_Call"}},"event_ts":1674571656505}';

        String loginBody = '{"event":"user.signed_in","payload":{"account_id":"kJdQOXj6TXeWcSfh_ysPVQ","object":{"date_time":"2023-01-24T14:47:36Z","email":"testzoommail23@mail.com","id":"p3x1bwrmsh6tnl_bxyrlca","presence_status":"Available"}},"event_ts":1674571656505}';

        String logoutBody = '{"event":"user.signed_out","payload":{"account_id":"kJdQOXj6TXeWcSfh_ysPVQ","object":{"date_time":"2023-01-24T14:47:36Z","email":"testzoommail23@mail.com","id":"p3x1bwrmsh6tnl_bxyrlca","presence_status":"Offline"}},"event_ts":1674571656505}';

        String ccLoginBody = '{ "event": "contact_center.user_login", "event_ts": 1627906944384, "payload": { "account_id": "D8cJuqWVQ623CI4Q8yQK0Q", "object": { "user_id": "ukAAkZKfROKMSw1bj_RDFQ", "display_name": "Jill Chill", "user_email": "testzoommail23@mail.com", "date_time": "2022-02-15T09:27:15Z"}}}';

        String ccLogoutBody = '{"event": "contact_center.user_logout","event_ts": 1627906944384,"payload": {"account_id": "D8cJuqWVQ623CI4Q8yQK0Q","object": {"user_id": "ukAAkZKfROKMSw1bj_RDFQ","display_name": "Jill Chill","user_email": "testzoommail23@mail.com","date_time": "2022-02-15T09:27:15Z"}}}';

        String ccStatusBody = '{"event": "contact_center.user_status_changed","event_ts": 1627906944384,"payload": {"account_id": "D8cJuqWVQ623CI4Q8yQK0Q","object": {"user_id": "ukAAkZKfROKMSw1bj_RDFQ","display_name": "Jill Chill","user_email": "testzoommail23@mail.com","previous_status_id": "2","previous_status_name": "Not Ready","previous_sub_status_id": "20","previous_sub_status_name": "Break","current_status_id": "2","current_status_name": "Not Ready","current_sub_status_id": "21","current_sub_status_name": "Meal","date_time": "2022-02-15T09:27:15Z"}}}';

        Map<String,Object> respMapstatus    = (Map<String,Object>)JSON.deserializeUntyped(statusBody);
        Map<String,Object> respMaplogin     = (Map<String,Object>)JSON.deserializeUntyped(loginBody);
        Map<String,Object> respMaplogout    = (Map<String,Object>)JSON.deserializeUntyped(logoutBody);
        Map<String,Object> respMapccLogin   = (Map<String,Object>)JSON.deserializeUntyped(ccLoginBody);
        Map<String,Object> respMapccLogout  = (Map<String,Object>)JSON.deserializeUntyped(ccLogoutBody);
        Map<String,Object> respMapccStatus  = (Map<String,Object>)JSON.deserializeUntyped(ccStatusBody);
        Test.startTest();
            ZoomWebhookController.checkZoomEvent(respMapstatus);
            ZoomWebhookController.checkZoomEvent(respMaplogin);
            ZoomWebhookController.checkZoomEvent(respMaplogout);
            ZoomWebhookController.checkZoomEvent(respMapccLogin);
            ZoomWebhookController.checkZoomEvent(respMapccLogout);
            ZoomWebhookController.checkZoomEvent(respMapccStatus);
        Test.stopTest();
        Zoom_Users_Info__c u = [SELECT Presence_Status__c FROM Zoom_Users_Info__c WHERE Email__c = 'testzoommail23@mail.com'];
        System.assertEquals('Offline', u.presence_status__c, 'Presence status should be Offline');
    }
}