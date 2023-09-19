global class SimplyCallout implements Queueable, Database.AllowsCallouts{

    global HttpCalloutMock mock = null;
      private List<Id> simplyProps;
      global SimplyCallout (List<Id> simplyProps){
          //Grab Proposal Id from Trigger
        this.simplyProps = simplyProps;
      }
  
      global void execute(QueueableContext context){
          String authKey;
          String urlAddress = 'https://api.principal.com/retirement/v1/external/sales/opportunities';
          HttpResponse authResponse = getSimplyAuthToken(urlAddress);
  
          Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(authResponse.getBody());
          authKey = (String) results.get('access_token');
  
          List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
          List<External_Response__c> externalResponses = new List<External_Response__c>();
          List<Proposal__c> proposalsToUpdate = new List<Proposal__c>();
  
          if(authResponse.getStatusCode() == 200){
              List<Proposal__c> proposalList = [SELECT Id,Client_Company_Name__c,
                                                          Contact_Phone_Number__c,
                                                          Company_State__c,
                                                          Company_EIN__c,
                                                          Company_Zip_Code__c,
                                                          Plan_Effective_Date__c,
                                                          Number_of_Employees__c,
                                                          Advisor_NPN__c,
                                                          Advisor_CRD__c,
                                                          Firm_Name__c,
                                                          TPA_Firm_Name__c,
                                                          TPA_EIN__c,
                                                          Principal_Opportunity_Id__c,
                                                          Principal_Opportunity_Stage__c,
                                                          Principal_Opportunity_Closed_Lost_Reason__c,
                                                          Company_Zip_Postal_Code__c,
                                                          Financial_Professional_Role__c,
                                                          Insurance_Agency_NPN__c
                                               FROM Proposal__c
                                               WHERE Id IN :simplyProps
                                               ];
  
              for(Proposal__c proposal :proposalList){
                  String jsonS = getSimplyPayload( proposal );
                  httpResponse response = sendSimplyCallout( jsonS, proposal, authKey, urlAddress );
  
                  if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                      Proposal__c proposalForUpdate = updateProposal( response, proposal );
                      proposalsToUpdate.add( proposalForUpdate );
                  }
                  else{
                      Messaging.SingleEmailMessage errEmail = sendErrorEmail( response, proposal );
                      emailsToSend.add( errEmail );
                  }
                  External_Response__c extResp = createExternalResponseRecord( response, proposal );
                  externalResponses.add( extResp );
                  Messaging.SingleEmailMessage errUbqtEmail = sendCalloutResultToDev( response, proposal );
                  emailsToSend.add( errUbqtEmail );
              }
              Messaging.sendEmail( emailsToSend );
              update proposalsToUpdate;
              insert externalResponses;
          } else {
              Messaging.SingleEmailMessage errAuthEmail = sendEmailAuthFaild( authResponse );
              emailsToSend.add( errAuthEmail );
              Messaging.sendEmail( emailsToSend );
          }
      }
  
      private static HttpResponse getSimplyAuthToken( String urlAddress ){
          Http authHttp = new Http();
          HttpRequest authRequest = new HttpRequest();
          String url = 'https://api.principal.com/auth/oauth2/realms/root/realms/PRINCIPAL/access_token';
          String token = 'ajlhZE5YNU9BSWdBOGNGaFpEeFQwMmpnbHkwOUFJSUo6U1pBQTY4V0tLZ2ZLbFBpWg==';
          authRequest.setEndpoint(url);
          authRequest.setMethod('POST');
          authRequest.setHeader('Authorization','Basic '+ token);
          authRequest.setHeader('Content-Type','application/x-www-form-urlencoded');
          authRequest.setBody('grant_type=client_credentials');
          authRequest.setTimeout(60000);
          HttpResponse authResponse = authHttp.send(authRequest);
          return authResponse;
      }
  
      private static httpResponse sendSimplyCallout(String jsonS, Proposal__c p, String authKey, String urlAddress){
          Http http = new Http();
          HttpRequest request = new HttpRequest();
          //If Proposal does not contain an Opportunity Id from Principal, insert as new Opportunity
          if(p.Principal_Opportunity_Id__c == null){
              request.setMethod('POST');
              request.setEndpoint(urlAddress);
          }
          //If Proposal contains an Opportunity Id from Principal, update existing Opportunity
          else{
              request.setMethod('PUT');
              request.setEndpoint(urlAddress + p.Principal_Opportunity_Id__c);
          }
          request.setHeader('Authorization', 'Bearer ' + authKey);
          request.setHeader('Content-Type','application/json');
          request.setBody(jsonS);
          request.setTimeout(60000);
          httpResponse response = http.send(request);
          return response;
      }
  
      private static Proposal__c updateProposal(httpResponse response, Proposal__c proposal){
          String body = String.valueOf(response.getBody().replace('"',''));
          if(body != null && body != ''){
              List<String> bodyRows = body.split(',');
              for (String bodyRow :bodyRows) {
                  if(bodyRow.contains(':')){
                      List<String> rowContents = bodyRow.split(':');
                      String label  = rowContents.size() > 0 ? rowContents[0].trim(): bodyRow;
                      String value  = rowContents.size() > 1 ? rowContents[1].trim(): bodyRow;
                      String value2 = rowContents.size() > 2 ? rowContents[2].trim(): bodyRow;
  
                      if( label == 'salesforceId'){
                          if(value.startsWith('006')){
                              proposal.Principal_Opportunity_Id__c = value;
                              proposal.Queued__c = false;
                              return proposal;
                          }
                          else if(value.startsWith('001')){
                              proposal.Principal_Account_Id__c = value;
                              proposal.Queued__c = false;
                              return proposal;
                          }
                      }
                  }
              }
          }
          return proposal;
      }
  
      private External_Response__c createExternalResponseRecord(HttpResponse response, Proposal__c proposal) {
          External_Response__c ext = new External_Response__c();
          ext.Response_Body__c = String.valueOf(response.getBody());
          ext.Proposal__c = proposal.Id;
          return ext;
      }
  
      private Messaging.SingleEmailMessage sendErrorEmail( HttpResponse response, Proposal__c proposal) {
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setToAddresses(new List<String> {'DLRISWSRSSALESANDMARKETINGONCALL@exchange.principal.com'});
          mail.setReplyTo('mchapa@myubiquity.com');
          mail.setSenderDisplayName('Proposal Sync Confirmation');
          mail.setSubject('Error - UBQT to PRINCIPAL API Request Unsuccessful');
          mail.setPlainTextBody(response.getBody() + '\n' + getSimplyPayload(proposal));
          return mail;
      }
  
      private Messaging.SingleEmailMessage sendCalloutResultToDev( HttpResponse response, Proposal__c proposal) {
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setToAddresses(new List<String> {'mchapa@myubiquity.com'});
          mail.setReplyTo('mchapa@myubiquity.com');
          mail.setSenderDisplayName('Proposal Sync Confirmation');
          mail.setSubject('Proposal Sent to Principal');
          mail.setPlainTextBody(response.getBody() + '\n' + getSimplyPayload(proposal));
          return mail;
      }
  
      private Messaging.SingleEmailMessage sendEmailAuthFaild( HttpResponse authResponse){
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          mail.setToAddresses(new List<String> {'mchapa@myubiquity.com'});
          mail.setReplyTo('mchapa@myubiquity.com');
          mail.setSenderDisplayName('Proposal Sync Confirmation');
          mail.setSubject('Simply Auth Token Callout Failed');
          mail.setPlainTextBody(authResponse.getBody());
          return mail;
      }
  
      public static String getSimplyPayload( Proposal__c proposal ){
          JSONGenerator gen = JSON.createGenerator(true);
          gen.writeStartObject();
          gen.writeFieldName('client');
          gen.writeStartObject();
          if(proposal.Client_Company_Name__c != null){
              gen.writeStringField('name', proposal.Client_Company_Name__c);
          }
          if(proposal.Contact_Phone_Number__c != null){
              gen.writeStringField('localPhone', proposal.Contact_Phone_Number__c);
          }
          if(proposal.Company_State__c != null){
              gen.writeStringField('mailingState', proposal.Company_State__c);
          }
          if(proposal.Company_Zip_Postal_Code__c != null && proposal.Company_Zip_Postal_Code__c != 0){
              gen.writeNumberField('mailingFullZip', proposal.Company_Zip_Postal_Code__c);
          }
          if(proposal.Company_EIN__c != null){
              gen.writeStringField('taxId', proposal.Company_EIN__c);
          }
          gen.writeEndObject();
          gen.writeFieldName('opportunity');
          gen.writeStartObject();
          if(proposal.Plan_Effective_Date__c != null){
              gen.writeDateField('contractEffectiveDate', proposal.Plan_Effective_Date__c);
          }
          if(proposal.Number_of_Employees__c != null){
              gen.writeNumberField('activeLivesCount', proposal.Number_of_Employees__c);
          }
          if(proposal.Principal_Opportunity_Stage__c != null){
              gen.writeStringField('stage', proposal.Principal_Opportunity_Stage__c);
          }
          if(proposal.Principal_Opportunity_Closed_Lost_Reason__c != null){
              gen.writeStringField('closedReason', proposal.Principal_Opportunity_Closed_Lost_Reason__c);
          }
              gen.writeEndObject();
          if(proposal.Advisor_NPN__c != null || proposal.Advisor_CRD__c != null){
              gen.writeFieldName('advisor');
              gen.writeStartObject();
          }
          if(proposal.Advisor_NPN__c != null){
              gen.writeStringField('npn', proposal.Advisor_NPN__c);
          }
          if(proposal.Advisor_CRD__c != null){
              gen.writeStringField('firmCrd', proposal.Advisor_CRD__c);
          }
          if((proposal.Advisor_NPN__c != null || proposal.Advisor_CRD__c != null) && proposal.Financial_Professional_Role__c != null){
              if(proposal.Financial_Professional_Role__c == 'RR'){
                  gen.writeStringField('role', 'Registered Rep');
              }
              else if(proposal.Financial_Professional_Role__c == 'IA'){
                  gen.writeStringField('role', 'Insurance Agent');
              }
              else if(proposal.Financial_Professional_Role__c == 'IAR'){
                  gen.writeStringField('role', proposal.Financial_Professional_Role__c);
              }
          }
          if((proposal.Advisor_NPN__c != null || proposal.Advisor_CRD__c != null) && proposal.Firm_Name__c != null){
              gen.writeStringField('firmName', proposal.Firm_Name__c);
          }
          if((proposal.Advisor_NPN__c != null || proposal.Advisor_CRD__c != null) && proposal.Insurance_Agency_NPN__c != null){
              gen.writeNumberField('firmNpn', proposal.Insurance_Agency_NPN__c);
          }
          if(proposal.Advisor_NPN__c != null || proposal.Advisor_CRD__c != null){
              gen.writeEndObject();
          }
          if(proposal.TPA_EIN__c != null){
              gen.writeFieldName('tpa');
              gen.writeStartObject();
          }
          if(proposal.TPA_EIN__c != null && proposal.TPA_Firm_Name__c != null){
              gen.writeStringField('firmName', proposal.TPA_Firm_Name__c);
          }
          if(proposal.TPA_EIN__c != null){
              gen.writeStringField('taxId', proposal.TPA_EIN__c);
              gen.writeEndObject();
          }
          gen.writeEndObject();
  
          String jsonS = gen.getAsString().replace('\n','');
          return jsonS;
      }
  }
  