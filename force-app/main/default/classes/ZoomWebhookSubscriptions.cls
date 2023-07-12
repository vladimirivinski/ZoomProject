// @RestResource(urlMapping='/zoom/webhooks/*')
global without sharing class ZoomWebhookSubscriptions {
    // @HttpPost
    // global static void doPost() {
    //     RestResponse response = RestContext.response;
    //     RestRequest request = RestContext.request;
    //     response.addHeader('Content-Type', 'application/json');
    //     String responseString = RestContext.request.requestBody.toString();

        // Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(responseString);
    //     System.debug('**************REQUEST*********************** \n' + request ); 
    //     System.debug('**************RESPONSE*********************** \n' + response ); 
    //     System.debug('****respMap \n' + responseString ); 
    //     // generateSignature(request, responseString);
    //     // ZoomWebhookController.checkZoomEvent(respMap); 
    //     response.responseBody = Blob.valueOf('{success; true, event: "Unknonw"}');
    //     response.statusCode =200;
    // }
}


    // private static String generateSignature(RestRequest request, String responseString) {
    //     System.debug('###################### REQUEST ######################  \n' + request );
    //     System.debug('###################### RESPONSE STRING ######################  \n' + responseString );
    //     //OAth
    //     String ZOOM_WEBHOOK_SECRET_TOKEN = 'm-jhZqG_Q-esm3kmaeBANw';
    //     Map<String, String> headers = request.headers;
    //     System.debug('###################### HEADERS ######################  \n' + headers);
    //     String signature = headers.get('x-zm-signature');
    //     System.debug('**************** SIGNATURE ***************** \n' + signature );

    //     Map<String, String> sigMap = new Map<String, String>();
    //     List<String> signatures = signature.split(',');
    //     System.debug('**************** SIGNATURES ***************** \n' + signatures );
        
    //     for (String kv : signatures) {
    //         System.debug('**************** KV ***************** \n' + kv );
    //         sigMap.put( kv.split('=')[0], kv.split('=')[1] );
    //     }
    //     System.debug('**************** SIGMap ***************** \n' + sigMap );
        
    //     String signature_payload = sigMap.get('v0') + '.'+responseString;
    //     System.debug('**************** signature_payload ***************** \n' + signature_payload );
    //     Blob input = Blob.valueOf(signature_payload);

    //     Blob privateKey = Blob.valueOf(ZOOM_WEBHOOK_SECRET_TOKEN);

    //     Blob hmac = Crypto.generateMac('HmacSHA256', input, privateKey);
    //     System.debug('**************** hmac ***************** \n' + hmac );
    //     String incomingSignature = sigMap.get('v0');
    //     System.debug('**************** \n Incoming signature' + incomingSignature );

    //     String response = (incomingSignature == EncodingUtil.convertToHex(hmac)) ? 'Signature verified' : 'Signature could not be verified';
    //     System.debug('**************** RESPONSE ***************** \n' + response );
    //     return response;
	// }



// const message = `v0:${request.headers['x-zm-request-timestamp']}:${JSON.stringify(request.body)}`

// const hashForVerify = crypto.createHmac('sha256', ZOOM_WEBHOOK_SECRET_TOKEN).update(message).digest('hex')

// const signature = `v0=${hashForVerify}`

// if (request.headers['x-zm-signature'] === signature) {
//   // Webhook request came from Zoom
// } else {
//   // Webhook request did not come from Zoom
// }

// {"event":"user.presence_status_updated",
//   "payload":{"account_id":"kJdQOXj6TXeWcSfh_ysPVQ",
//                 "object":{
//                         "date_time":"2022-12-05T23:01:43Z",  
//                         "email":"ckoshkin@myubiquity.com",
//                         "id":"9tjm_dgtrhofhm3iccw1ma",
//                         "presence_status":"Offline"
//                         }
//                 },
//     "event_ts":1670281303146}




// require('dotenv').config();
// const express = require('express');
// const bodyParser = require('body-parser');
// const crypto = require('crypto');
// const app = express();
// const port = process.env.PORT || 4000;
// app.use(bodyParser.json());
// app.get('/', (req, res) => {
//   res.status(200);
//   res.send(`Webhook Sample Node.js successfully running. Set this URL with the /webhook path as your apps Event notification endpoint URL. https://github.com/zoom/webhook-sample-node.js`);
// });
// app.post('/webhook', (req, res) => {
//   var response;
//   console.log(req.body);
//   console.log(req.headers);

//   // construct the message string
//   const message = `v0:${req.headers['x-zm-request-timestamp']}:${JSON.stringify(req.body)}`;
//   const hashForVerify = crypto.createHmac('sha256', process.env.ZOOM_WEBHOOK_SECRET_TOKEN).update(message).digest('hex');

//   // hash the message string with your Webhook Secret Token and prepend the version semantic
//   const signature = `v0=${hashForVerify}`;

//   // you validating the request came from Zoom https://marketplace.zoom.us/docs/api-reference/webhook-reference#notification-structure
//   if (req.headers['x-zm-signature'] === signature) {
//     // Zoom validating you control the webhook endpoint https://marketplace.zoom.us/docs/api-reference/webhook-reference#validate-webhook-endpoint
//     if (req.body.event === 'endpoint.url_validation') {
//       const hashForValidate = crypto.createHmac('sha256', process.env.ZOOM_WEBHOOK_SECRET_TOKEN).update(req.body.payload.plainToken).digest('hex');
//       response = {
//         message: {
//           plainToken: req.body.payload.plainToken,
//           encryptedToken: hashForValidate
//         },
//         status: 200
//       };
//       console.log(response.message);
//       res.status(response.status);
//       res.json(response.message);
//     } else {
//       response = {
//         message: 'Authorized request to Webhook Sample Node.js.',
//         status: 200
//       };
//       console.log(response.message);
//       res.status(response.status);
//       res.json(response);

//       // business logic here, example make API request to Zoom or 3rd party
//     }
//   } else {
//     response = {
//       message: 'Unauthorized request to Webhook Sample Node.js.',
//       status: 401
//     };
//     console.log(response.message);
//     res.status(response.status);
//     res.json(response);
//   }
// });




// app.post('/webhook', (req, res) => {
//     var response
//     console.log(req.body)
//     console.log(req.headers)
//     // construct the message string
//     const message = `v0:${req.headers['x-zm-request-timestamp']}:${JSON.stringify(req.body)}`
//     const hashForVerify = crypto.createHmac('sha256', process.env.ZOOM_WEBHOOK_SECRET_TOKEN).update(message).digest('hex')
//     // hash the message string with your Webhook Secret Token and prepend the version semantic
//     const signature = `v0=${hashForVerify}`
//     // you validating the request came from Zoom https://marketplace.zoom.us/docs/api-reference/webhook-reference#notification-structure
//     if (req.headers['x-zm-signature'] === signature) {
//       // Zoom validating you control the webhook endpoint https://marketplace.zoom.us/docs/api-reference/webhook-reference#validate-webhook-endpoint
//       if(req.body.event === 'endpoint.url_validation') {
//         const hashForValidate = crypto.createHmac('sha256', process.env.ZOOM_WEBHOOK_SECRET_TOKEN).update(req.body.payload.plainToken).digest('hex')
//         response = {
//           message: {
//             plainToken: req.body.payload.plainToken,
//             encryptedToken: hashForValidate
//           },
//           status: 200
//         }
//         console.log(response.message)
//         res.status(response.status)
//         res.json(response.message)
//       } else {
//         response = { message: 'Authorized request to Webhook Sample Node.js.', status: 200 }
//         console.log(response.message)
//         res.status(response.status)
//         res.json(response)
//         // business logic here, example make API request to Zoom or 3rd party
//       }
//     } else {
//       response = { message: 'Unauthorized request to Webhook Sample Node.js.', status: 401 }
//       console.log(response.message)
//       res.status(response.status)
//       res.json(response)
//     }
//   })