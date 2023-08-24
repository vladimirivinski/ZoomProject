@isTest
private class ZoomWebhookControllerTest {

    @TestSetup
    static void makeData(){
        CallCenter cc =[SELECT Id FROM CallCenter LIMIT 1];
        Profile profId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = new User();
        usr.Email = 'johnktest@mail.com';
        usr.Username = 'johnktest@mail.com';
        usr.FirstName = 'Test';
        usr.LastName = 'User';
        usr.Alias = 'tuser';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.isActive = true;
        usr.ProfileId = profId.Id;
        usr.CallCenterId = cc.Id;
        insert usr;

        User createdUser = [SELECT Id, Email, Name FROM User WHERE Username = 'johnktest@mail.com' LIMIT 1];

        Zoom_Users_Info__c zoomUser = new Zoom_Users_Info__c();
        zoomUser.User__c = createdUser.Id;
        zoomUser.Email__c= createdUser.Email;
        zoomUser.Name = createdUser.Name;
        zoomUser.Presence_Status__c = 'Away';
        zoomUser.Status_Updated__c = DateTime.now();
        zoomUser.Tracking_Date__c = Date.today();
        zoomUser.Available__c = 0;
        zoomUser.Away__c = 0;
        zoomUser.In_Calendar_Event__c = 0;
        zoomUser.In_Meeting__c = 0;
        zoomUser.Offline__c = 0;
        zoomUser.On_Phone_Call__c = 0;
        zoomUser.Presenting__c = 0;
        zoomUser.Do_Not_Disturb__c = 0;
        insert zoomUser;
    }

    @isTest
    private static void checkZoomEventUpdatedStatusTest(){
        String requestBody = '{"event":"user.presence_status_updated","payload":{"account_id":"kJdQOXj6TXeWcSfh_ysPVQ","object":{"date_time":"2023-01-24T14:47:36Z","email":"johnktest@mail.com","id":"p3x1bwrmsh6tnl_bxyrlca","presence_status":"On_Phone_Call"}},"event_ts":1674571656505}';
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);
        Test.startTest();
        ZoomWebhookController.checkZoomEvent(respMap);
        Test.stopTest();
        Zoom_Users_Info__c u = [SELECT Presence_Status__c FROM Zoom_Users_Info__c WHERE Email__c = 'johnktest@mail.com'];
        System.assertEquals('On_Phone_Call', u.presence_status__c, 'Presence status should be On_Phone_Call');
    }

    @isTest
    private static void checkZoomEventSignInStatusTest(){
        String requestBody = '{"event":"user.signed_in","payload":{"account_id":"kJdQOXj6TXeWcSfh_ysPVQ","object":{"date_time":"2023-01-24T14:47:36Z","email":"johnktest@mail.com","id":"p3x1bwrmsh6tnl_bxyrlca","presence_status":"Available"}},"event_ts":1674571656505}';
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);
        Test.startTest();
        ZoomWebhookController.checkZoomEvent(respMap);
        Test.stopTest();
        Zoom_Users_Info__c u = [SELECT Presence_Status__c FROM Zoom_Users_Info__c WHERE Email__c = 'johnktest@mail.com'];
        System.assertEquals('Available', u.presence_status__c, 'Presence status should be Available');
    }

    @isTest
    private static void checkZoomEventSignOutStatusTest(){
        String requestBody = '{"event":"user.signed_out","payload":{"account_id":"kJdQOXj6TXeWcSfh_ysPVQ","object":{"date_time":"2023-01-24T14:47:36Z","email":"johnktest@mail.com","id":"p3x1bwrmsh6tnl_bxyrlca","presence_status":"Offline"}},"event_ts":1674571656505}';
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);
        Test.startTest();
        ZoomWebhookController.checkZoomEvent(respMap);
        Test.stopTest();
        Zoom_Users_Info__c u = [SELECT Presence_Status__c FROM Zoom_Users_Info__c WHERE Email__c = 'johnktest@mail.com'];
        System.assertEquals('Offline', u.presence_status__c, 'Presence status should be Offline');
    }
}