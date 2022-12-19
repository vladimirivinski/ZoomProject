@RestResource(urlMapping='/zoom/webhooks/*')
global without sharing class DemoZoomWebhookSubscriptions {
    
    @HttpPost
    global static void doPost() {
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.request;
        response.addHeader('Content-Type', 'application/json');
        String responseString = RestContext.request.requestBody.toString();
        //TODO: Creaate Cypto class for Access TOKEN
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(responseString);
        System.debug( System.LoggingLevel.DEBUG, '****respMap \n' + respMap ); 
        
        // TODO: Create WRAPPER FOR RESPONSE
        ZoomWebhookSubscriptionsController.checkZoomEvent(respMap); 
        
        response.responseBody = Blob.valueOf('{success; true, event: "Unknonw"}');
        response.statusCode =200;
    }
}

//================================================================================================
//================================================================================================

// {"event":"user.presence_status_updated",
// "payload":{"account_id":"kJdQOXj6TXeWcSfh_ysPVQ","object":{"date_time":"2022-12-05T23:01:43Z",  "email":"ckoshkin@myubiquity.com","id":"9tjm_dgtrhofhm3iccw1ma","presence_status":"Offline"}},"event_ts":1670281303146}

