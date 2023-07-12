global class SimplyCallout implements Queueable, Database.AllowsCallouts{

	global HttpCalloutMock mock = null;
    private List<Id> simplyProps;
    global SimplyCallout(List<Id> simplyProps){
        //Grab Proposal Id from Trigger
    	this.simplyProps = simplyProps;
    }
    global void execute(QueueableContext context){
        //Generate Authentication Key for use in adding/updating records in Principal Salesforce instance
        String authKey;
        Http authHttp = new Http();
        HttpRequest authRequest = new HttpRequest();
        authRequest.setEndpoint('https://api.principal.com/auth/oauth2/realms/root/realms/PRINCIPAL/access_token');
        authRequest.setMethod('POST');
        authRequest.setHeader('Authorization','Basic ajlhZE5YNU9BSWdBOGNGaFpEeFQwMmpnbHkwOUFJSUo6U1pBQTY4V0tLZ2ZLbFBpWg==');
        authRequest.setHeader('Content-Type','application/x-www-form-urlencoded');
        authRequest.setBody('grant_type=client_credentials');
        authRequest.setTimeout(60000);
        HttpResponse authResponse = authHttp.send(authRequest);
        if(authResponse.getStatusCode() == 200){
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(authResponse.getBody());
            authKey = (String) results.get('access_token');

            //Query for Proposal object, and translate Proposal values to Principal Opportunity values in JSON format
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
                                             WHERE Id IN :simplyProps FOR UPDATE];
            for(Proposal__c p :proposalList){
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeFieldName('client');
                gen.writeStartObject();
                if(p.Client_Company_Name__c != null){
                    gen.writeStringField('name', p.Client_Company_Name__c);
                }
                if(p.Contact_Phone_Number__c != null){
                    gen.writeStringField('localPhone', p.Contact_Phone_Number__c);
                }
                if(p.Company_State__c != null){
                    gen.writeStringField('mailingState', p.Company_State__c);
                }
                if(p.Company_Zip_Postal_Code__c != null && p.Company_Zip_Postal_Code__c != 0){
                    gen.writeNumberField('mailingFullZip', p.Company_Zip_Postal_Code__c);
                }
                if(p.Company_EIN__c != null){
                    gen.writeStringField('taxId', p.Company_EIN__c);
                }
                gen.writeEndObject();
                gen.writeFieldName('opportunity');
                gen.writeStartObject();
                if(p.Plan_Effective_Date__c != null){
                    gen.writeDateField('contractEffectiveDate', p.Plan_Effective_Date__c);
                }
                if(p.Number_of_Employees__c != null){
                    gen.writeNumberField('activeLivesCount', p.Number_of_Employees__c);
                }
                if(p.Principal_Opportunity_Stage__c != null){
                    gen.writeStringField('stage', p.Principal_Opportunity_Stage__c);
                }
                if(p.Principal_Opportunity_Closed_Lost_Reason__c != null){
                    gen.writeStringField('closedReason', p.Principal_Opportunity_Closed_Lost_Reason__c);
                }
                    gen.writeEndObject();
                if(p.Advisor_NPN__c != null || p.Advisor_CRD__c != null){
                    gen.writeFieldName('advisor');
                    gen.writeStartObject();
                }
                if(p.Advisor_NPN__c != null){
                    gen.writeStringField('npn', p.Advisor_NPN__c);
                }
                if(p.Advisor_CRD__c != null){
                    gen.writeStringField('firmCrd', p.Advisor_CRD__c);
                }
                if((p.Advisor_NPN__c != null || p.Advisor_CRD__c != null) && p.Financial_Professional_Role__c != null){
                    if(p.Financial_Professional_Role__c == 'RR'){
                        gen.writeStringField('role', 'Registered Rep');
                    }
                    else if(p.Financial_Professional_Role__c == 'IA'){
                        gen.writeStringField('role', 'Insurance Agent');
                    }
                    else if(p.Financial_Professional_Role__c == 'IAR'){
                        gen.writeStringField('role', p.Financial_Professional_Role__c);
                    }
                }
                if((p.Advisor_NPN__c != null || p.Advisor_CRD__c != null) && p.Firm_Name__c != null){
                    gen.writeStringField('firmName', p.Firm_Name__c);
                }
                if((p.Advisor_NPN__c != null || p.Advisor_CRD__c != null) && p.Insurance_Agency_NPN__c != null){
                    gen.writeNumberField('firmNpn', p.Insurance_Agency_NPN__c);
                }
                if(p.Advisor_NPN__c != null || p.Advisor_CRD__c != null){
                    gen.writeEndObject();
                }
                if(p.TPA_EIN__c != null){
                    gen.writeFieldName('tpa');
                    gen.writeStartObject();
                }
                if(p.TPA_EIN__c != null && p.TPA_Firm_Name__c != null){
                    gen.writeStringField('firmName', p.TPA_Firm_Name__c);
                }
                if(p.TPA_EIN__c != null){
                    gen.writeStringField('taxId', p.TPA_EIN__c);
                    gen.writeEndObject();
                }
                gen.writeEndObject();

                String jsonS = gen.getAsString().replace('\n','');
                Integer result = jsonS.length();

                Http http = new Http();
                HttpRequest request = new HttpRequest();
                //If Proposal does not contain an Opportunity Id from Principal, insert as new Opportunity
                if(p.Principal_Opportunity_Id__c == null){
                    request.setMethod('POST');
                    request.setEndpoint('https://api.principal.com/retirement/v1/external/sales/opportunities');
                }
                //If Proposal contains an Opportunity Id from Principal, update existing Opportunity
                else{
                    request.setMethod('PUT');
                    request.setEndpoint('https://api.principal.com/retirement/v1/external/sales/opportunities/' + p.Principal_Opportunity_Id__c);
                }
                request.setHeader('Authorization', 'Bearer ' + authKey);
                request.setHeader('Content-Type','application/json');
                request.setBody(jsonS);
                request.setTimeout(60000);
                httpResponse response = http.send(request);
                //If callout is successful, add Principal Salesforce Ids to Proposal and uncheck Queued field
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                    String body = String.valueOf(response.getBody().replace('"',''));
                    if(body != null && body != ''){
                        String[] bodyRows = body.split(',');
                        for (String bodyRow :bodyRows) {
                            if(bodyRow.contains(':')){
                                String[] rowContents = bodyRow.split(':');
                                String label  = rowContents.size() > 0 ? rowContents[0].trim(): bodyRow;
                                String value  = rowContents.size() > 1 ? rowContents[1].trim(): bodyRow;
                                String value2 = rowContents.size() > 2 ? rowContents[2].trim(): bodyRow;
                                switch on label {
                                    when 'salesforceId'{
                                        if(value.startsWith('006')){
                                            p.Principal_Opportunity_Id__c = value;
                                            p.Queued__c = false;
                                            update p;
                                        }
                                        else if(value.startsWith('001')){
                                            p.Principal_Account_Id__c = value;
                                            p.Queued__c = false;
                                            update p;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //If callout is unsuccessful, send email to Principal team
                else{
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {'DLRISWSRSSALESANDMARKETINGONCALL@exchange.principal.com'};
                    mail.setToAddresses(toAddresses);
                    mail.setReplyTo('mchapa@myubiquity.com');
                    mail.setSenderDisplayName('Proposal Sync Confirmation');
                    mail.setSubject('Error - UBQT to PRINCIPAL API Request Unsuccessful');
                    mail.setPlainTextBody(response.getBody() + '\n' + JsonS);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                //Insert External Response record linked to Proposal with response from callout
                External_Response__c ext = new External_Response__c();
                ext.Response_Body__c = String.valueOf(response.getBody());
                ext.Proposal__c = p.id;
                insert ext;

                //Send callout results to dev
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {'mchapa@myubiquity.com'};
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('mchapa@myubiquity.com');
                mail.setSenderDisplayName('Proposal Sync Confirmation');
                mail.setSubject('Proposal Sent to Principal');
                mail.setPlainTextBody(response.getBody() + '\n' + JsonS);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
}