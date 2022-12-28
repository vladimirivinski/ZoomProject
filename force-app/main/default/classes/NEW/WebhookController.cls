@RestResource(urlMapping='/zoomhooks/*')
global without sharing class WebhookController {
    
    @HttpPost
    global static void handleWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody.toString();
        WebhookController.generateSignature(req, res, requestBody);
    }


     private static void generateSignature(RestRequest req, RestResponse res, String requestBody) {
        String ZOOM_WEBHOOK_SECRET_TOKEN  = 'LNAZUD7aSHyLWz-vhC8OHw';
        Map<String, Object> response;

        String message = 'v0:' + req.headers.get('x-zm-request-timestamp') + ':' + requestBody;
        Blob mac = Crypto.generateMac('HmacSHA256', Blob.valueOf(message), Blob.valueOf(ZOOM_WEBHOOK_SECRET_TOKEN));
        String hashForVerify = EncodingUtil.convertToHex(mac);
        String signature = 'v0=' + hashForVerify;

        ReqBody reqBody = (ReqBody)JSON.deserialize(requestBody, ReqBody.class);
        String event = (String)reqBody.event;
        String plainToken = (String)reqBody.payload.plainToken;
        

        if (req.headers.get('x-zm-signature') == signature) {
            if (event == 'endpoint.url_validation') {
                Blob mac1 = Crypto.generateMac('HmacSHA256', Blob.valueOf(plainToken), Blob.valueOf(ZOOM_WEBHOOK_SECRET_TOKEN));
                String hashForValidate = EncodingUtil.convertToHex(mac1);
                response = new Map<String, Object>{
                    'message' => new Map<String, String>{
                        'plainToken' => plainToken,
                        'encryptedToken' => hashForValidate
                    },
                    'status' => 200
                };
                res.statusCode = (Integer)response.get('status');
                res.responseBody = Blob.valueOf(JSON.serialize(response.get('message')));
            } 
            else  {
                response = new Map<String, Object>{
                    'message' => 'Authorized request to Webhook.',
                    'status' => 200
                };
                res.statusCode = (Integer)response.get('status');
                res.responseBody = Blob.valueOf(JSON.serialize(response.get('response')));
                // TODO: Refactore
                Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);
                ZoomWebhookController.checkZoomEvent(respMap);
            }
        } else {
            response = new Map<String, Object>{
                'message' => 'Unauthorized request to Webhook.',
                'status' => 401
            };
            res.statusCode = (Integer)response.get('status');
            res.responseBody = Blob.valueOf(JSON.serialize(response.get('response')));
        }
    }
    public class ReqBody {
        public String event;
        public Payload payload;
    }
    public class Payload {
        public String plainToken;
    }
  

}

