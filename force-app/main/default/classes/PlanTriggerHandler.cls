global class PaycorEmailHandler implements Messaging.InboundEmailHandler {
	global static final List<String> VALID_STATES = new List<String>{
		'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
	};

	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		String htmlBodyEmail = email.htmlBody;
        Map<String, String> inboundHtmlFieldsValueMap = new Map<String, String>();
        if(htmlBodyEmail != null && htmlBodyEmail != ''){
            String unescapedHtmlBody = htmlBodyEmail.unescapeHtml4();
            String clearString = unescapedHtmlBody.replaceAll('=0A=', '');
            List<String> splitedEmailHtml = clearString.split('</p>');
            inboundHtmlFieldsValueMap = PaycorEmailHandler.parseEmailBody(splitedEmailHtml);
        }

		String emailPlainTextBody = email.plainTextBody;
        // List<String> splitedEmailText = new List<String>();
        // if(emailPlainTextBody != null || emailPlainTextBody != ''){
        //     String unescapedPlainTextBody = emailPlainTextBody.unescapeHtml4();
        //     String clearTagsStr = emailPlainTextBody.replaceAll('<[^>]+>', '');
        //     String clearString = clearTagsStr.replaceAll('=0A=', '');
        //     splitedEmailText = clearString.split('\n');
        // }
		// Map<String, String> inboundTextFieldsValueMap = PaycorEmailHandler.parseEmailBody(splitedEmailText);
		// Map<String, String> inboundFieldsValueMap = inboundHtmlFieldsValueMap.size() > inboundTextFieldsValueMap.size() ? inboundHtmlFieldsValueMap : inboundTextFieldsValueMap;

        PaycorEmailHandler.createLeadFromPaycorEmail(inboundHtmlFieldsValueMap, htmlBodyEmail);

		return null;
	}

	private static Map<String, String> parseEmailBody(List<String> splitedList){
		Map<String, String> inboundFieldsValueMap = new Map<String, String>();
		for (String s : splitedList){
			String unescaped = s.unescapeHtml4();
			String clearStr  = s.replaceAll('<[^>]+>', '');
			if (s.contains(':')){
				String key   = clearStr.substringBefore(':').trim();
				String value = clearStr.substringAfter(':').trim();
				inboundFieldsValueMap.put(key, value);
			}
		}
		return inboundFieldsValueMap;
	}

	private static void createLeadFromPaycorEmail(Map<String, String> inboundFieldsValueMap, String htmlBodyEmail) {
		String zipPattern = '^\\d{5}(?:[-\\s]\\d{4})?$|^\\d{9}$'; // 99999-9999 or 99999
		Pattern regex = Pattern.compile(zipPattern);
		String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
		Pattern emailPattern = Pattern.compile(emailRegex);

		String contactName = 'Contact Name',
			   address = 'Address',
			   contactEmail = 'Contact Email',
			   contactPhone = 'Contact Phone',
			   contactTitle = 'Contact Title',
			   companyName = 'Company Name',
			   companyFEIN = 'Company FEIN',
			   website = 'Website',
			   employees = 'Employees',
			   comments = 'Comments',
			   industry = 'Industry',
			   activeNumberOfEmployees = 'Active # of Employees In Relationship',
			   paycorClientID = 'Paycor Client ID',
			   referredByEmail = 'Referred by email',
			   referredByName = 'Referred by name';

		Lead newLead = new Lead();

		for (String key : inboundFieldsValueMap.keySet()) {
			// String value = !String.isBlank(inboundFieldsValueMap.get(key).trim())? inboundFieldsValueMap.get(key).trim(): null;
			String value =  inboundFieldsValueMap.get(key).trim();

			if (key == contactName) {
				List<String> fullName = value.split(' ');
				String firstName = fullName.size() > 0 ? fullName[0] : value;
				String lastName = fullName.size() > 1 ? fullName[1] : value;
				newLead.FirstName = firstName;
				newLead.LastName = lastName;
			}
			if (key == address) {
				List<String> fullAdd = value.split(',');
				if (fullAdd.size() > 4) {
					String lStreet = fullAdd.size() > 0 ? fullAdd[0].trim() : null;
					String lCity = fullAdd.size() > 2 ? fullAdd[2].trim() : null;
					String lState = fullAdd.size() > 3? fullAdd[3].trim(): null;
					String lZip = fullAdd.size() > 4 ? fullAdd[4].trim() : null;
					newLead.Street = lStreet;
					newLead.City = lCity;
					newLead.State = VALID_STATES.contains(lState) ? lState : null;
					newLead.PostalCode = regex.matcher(lZip).matches() ? lZip : null;
				} else  {
					String lStreet = fullAdd.size() > 0 ? fullAdd[0].trim() : null;
					String lCity = fullAdd.size() > 1 ? fullAdd[1].trim() : null;
					String lState = fullAdd.size() > 2 ? fullAdd[2].trim() : null;
					String lZip = fullAdd.size() > 3 ? fullAdd[3].trim() : null;
					newLead.Street = lStreet;
					newLead.City = lCity;
					newLead.State = VALID_STATES.contains(lState) ? lState : null;
					newLead.PostalCode = regex.matcher(lZip).matches() ? lZip : null;
				}
			}
			if (key == contactEmail) {
				Matcher emailMatcher = emailPattern.matcher(value);
				newLead.email = emailMatcher.matches() ? value.trim() : null;
            }
			if (key == contactPhone){
                newLead.Phone = value.length() < 40 ? value.trim() : value.substring(0, 40);
            }
			if (key == contactTitle){
                newLead.Title = value.length() < 128 ? value.trim() : value.substring(0, 128);
            }
			if (key == companyName){
				newLead.Company = value.trim();
            }
			if (key == companyFEIN){
                newLead.Company_FEIN__c = value.length() < 9 ? value.trim() : value.substring(0, 9);
            }
			if (key == website){
                newLead.Website = value.length() < 255 ? String.valueof(value) : null;
            }
			if (key == employees){
                String val = value.trim();
                newLead.NumberOfEmployees = String.isNotBlank(val) && val.isNumeric() ? Integer.valueOf(val) : 0;
            }
			if (key == comments){
                newLead.Description = value;
            }
			if (key == industry){
                newLead.Industry = String.isNotBlank(value) ? value : null;
            }
			if (key == activeNumberOfEmployees){
                String val = value.trim();
                newLead.Active_of_Employees_In_Relationship__c = String.isNotBlank(val) && val.isNumeric() ? Integer.valueOf(val) : 0;
            }
			if (key == paycorClientID){
                newLead.Paycor_Client_ID__c = value;
            }
			if (key == referredByEmail){
                newLead.Referrer_s_Email__c = value;
            }
			if (key == referredByName){
                newLead.Referral_Info_Last_Name__c = value;
            }
		}
		if (newLead.LastName == null || newLead.LastName == ' ' || String.isBlank(newLead.LastName)) {
			newLead.LastName = 'Paycor Lead';
		}
		if (newLead.Company == null || newLead.Company == ' ' || String.isBlank(newLead.Company)) {
			newLead.Company = 'Unknown Company';
		}
        newLead.LeadSource = 'HCM';
        newLead.LeadSourceDetail__c = 'Paycor';
        newLead.Method_of_First_Contact__c = 'Partner Referral';
        newLead.Product_Type__c = '401(k)';
        newLead.OwnerId = '00G37000000ksAD';
        newLead.PaycorEmail__c = htmlBodyEmail;
		try {
			insert newLead;
		} catch (System.exception e) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<String> toAddresses = new List<String>{'mchapa@myubiquity.com'};
			mail.setToAddresses(toAddresses);
			mail.setReplyTo('mchapa@myubiquity.com');
			mail.setSenderDisplayName('Apex Error Message - PaycorEmailHandlerNew.createLeadFromPaycorEmail()');
			mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
			mail.setPlainTextBody(e.getMessage() + '\n' + htmlBodyEmail);
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
		}
	}
}

// =========================================================================================================================================================================
// ====================================OLD CLASS============================================================================================================================
// =========================================================================================================================================================================

// global static final List<String> VALID_STATES = new List<String>{'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming'};

// global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

// 	String zipPattern = '^\\d{5}(?:[-\\s]\\d{4})?$|^\\d{9}$'; // 99999-9999 or 99999
// 	Pattern regex = Pattern.compile(zipPattern);

// 	String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
// 	Pattern emailPattern = Pattern.compile(emailRegex);

// 	//Injests contents of emails sent from Email Service address
// 	  Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

// 	//Initializes relevant strings to be used in Class
// 	String body = '', subject = '', emailAddress='', failedDML='', label = '', value = '', value2 = '';
// 	Lead newLead    = new Lead();
// 	//Maps body of email to String
// 	body 			= email.plainTextBody;
// 	Integer maxSize = 255;

// 	if(body != null && body != ''){
// 		// Create normolized row String for the situation if row nessasary row without : has \n
// 		String[] emailBodyRows = body.split('\n');
// //===================================================================================================
// //===================================================================================================
// 		// List<String> normalizedEmailBodyRows = new List<String>();
// 		// for(String line : emailBodyRows) {
// 		//     if((normalizedEmailBodyRows.isEmpty() && !line.contains(':')) || line.contains(':')){
// 		//         normalizedEmailBodyRows.add(line.trim());
// 		//     } else if (!line.contains(':')) {
// 		//         Integer lastIndex = normalizedEmailBodyRows.size() -1;
// 		//         normalizedEmailBodyRows[lastIndex] = normalizedEmailBodyRows[lastIndex] + ' ' + line.trim();
// 		//     }
// 		// }
// //===================================================================================================
// //===================================================================================================
// 		//Separate body of email into separate strings, broken by line breaks in the text
// 		for (String bodyRow:emailBodyRows) {
// 			System.debug('bodyRow: ' + bodyRow);
// 			//Iterate over list of email body strings
// 			if(bodyRow.contains(':')){
// 				//Separate each row at the colon if found. Anything left of the colon is the label, anything to the right is each label's value
// 				String[] rowContents = bodyRow.split(':');
// 					label  = rowContents.size() > 0 ? rowContents[0].trim(): bodyRow;
// 					value  = rowContents.size() > 1 ? rowContents[1].trim(): bodyRow;
// 					value2 = rowContents.size() > 2 ? rowContents[2].trim(): bodyRow;
// 					switch on label {
// 						//for each label, add associated value to new Lead
// 						// when 'Alliance' {
// 						//     continue;
// 						// }
// 						when 'Contact Name' {
// 							String[] fullName 								    = value.split(' ');
// 							String firstName  								    = fullName.size() > 0 ? fullName[0] : value;
// 							String lastName   								    = fullName.size() > 1 ? fullName[1] : value;
// 							newLead.FirstName 								    = firstName;
// 							newLead.LastName  								    = lastName;
// 							}
// 						when 'Address' {
// 							String[] fullAdd   								    = value.split(',');

// 							if(fullAdd.size() > 4){
// 								String lStreet 	   								= fullAdd.size() > 0 ? fullAdd[0].trim() : null;
// 								String lCity 	  								= fullAdd.size() > 2 ? fullAdd[2].trim() : null;
// 								String lState 	   								= fullAdd.size() > 3 ? fullAdd[3].trim() : null;
// 								String lZip 	   								= fullAdd.size() > 4 ? fullAdd[4].trim() : null;
// 								newLead.Street 	   								= lStreet;
// 								newLead.City 	   								= lCity;
// 								newLead.State 	   								= VALID_STATES.contains(lState) ? lState : null;
// 								newLead.PostalCode 								= regex.matcher(lZip).matches() ? lZip : null;
// 							}else {
// 								String lStreet 	   								= fullAdd.size() > 0 ? fullAdd[0].trim() : null;
// 								String lCity 	  								= fullAdd.size() > 1 ? fullAdd[1].trim() : null;
// 								String lState 	   								= fullAdd.size() > 2 ? fullAdd[2].trim() : null;
// 								String lZip 	   								= fullAdd.size() > 3 ? fullAdd[3].trim() : null;
// 								newLead.Street 	   								= lStreet;
// 								newLead.City 	   								= lCity;
// 								newLead.State 	   								= VALID_STATES.contains(lState) ? lState : null;
// 								newLead.PostalCode 								= regex.matcher(lZip).matches() ? lZip : null;
// 							}
// 						}
// 						when 'Contact Email' {
// 							Matcher emailMatcher = emailPattern.matcher(value);
// 							newLead.email = emailMatcher.matches() ? String.valueof(value.replace('<mailto','')) : null;
// 						}
// 						when 'Contact Phone' {
// 							newLead.Phone 									    = value;
// 						}
// 						when 'Contact Title' {
// 							newLead.Title 										= value;
// 						}
// 						when 'Company Name' {
// 								newLead.Company 								= value;
// 						}
// 						when 'Company FEIN' {
// 							newLead.Company_FEIN__c 							= value;
// 						}
// 						when 'Website' {
// 							if(value == 'https' || value == 'http'){
// 								newLead.Website 								= String.valueof(value + value2);
// 							}
// 							else{
// 								newLead.Website 								= value;
// 							}
// 						}
// 						when 'Employees' {
// 							if(!String.isBlank(value)){
// 								newLead.NumberOfEmployees 				    	= integer.valueof(value.replace(',', ''));
// 							}
// 							else{
// 								newLead.NumberOfEmployees 						= 0;
// 							}
// 						}
// 						when 'Comments' {
// 							newLead.Lead_Notes__c 								= value;
// 						}
// 						when 'Industry' {
// 							newLead.Industry 									= value;
// 						}
// 						when 'Active # of Employees In Relationship'{
// 							if(!String.isBlank(value)){
// 								String[] spaceSaver = value.split(' ');
// 								newLead.Active_of_Employees_In_Relationship__c  = integer.valueof(spaceSaver[0].replace(',', ''));
// 								newLead.Paycor_Client_ID__c 					= value2;
// 							}
// 							else{
// 								newLead.Active_of_Employees_In_Relationship__c  = 0;
// 							}
// 						}
// 						when 'Paycor Client ID' {
// 							newLead.Paycor_Client_ID__c 						= value;
// 						}
// 						when 'Referred by email' {

// 							Matcher emailMatcher = emailPattern.matcher(value);
// 							newLead.Referrer_s_Email__c = emailMatcher.matches() ? String.valueof(value.replace('<mailto','')) : null;
// 							// newLead.Referrer_s_Email__c 						= String.valueof(value.replace('<mailto',''));
// 						}
// 						when 'Referred by name' {
// 							newLead.Referral_Info_Last_Name__c 					= value;
// 						}
// 					}
// 				}
// 			}
// 		}
// 	//Assign default values to required fields if labels are not found above
// 	if(newLead.LastName == null || newLead.LastName == ' ' || String.isBlank(newLead.LastName)){
// 		newLead.LastName 				   = 'Paycor Lead';
// 	}
// 	if(newLead.Company == null || newLead.Company == ' ' || String.isBlank(newLead.Company)){
// 		newLead.Company 				   = 'Unknown Company';
// 	}
// 		//Assign defaults required for every Paycor sourced Lead
// 		newLead.LeadSource 				   = 'HCM';
// 		newLead.LeadSourceDetail__c 	   = 'Paycor';
// 		newLead.Method_of_First_Contact__c = 'Partner Referral';
// 		newLead.Product_Type__c 		   = '401(k)';
// 		newLead.OwnerId         		   = '00G37000000ksAD';
// 		newLead.PaycorEmail__c = email.htmlBody;

// 		//Trim website values if received value is too large
// 		if(newLead.Website != null && newLead.Website.length() > maxSize){
// 			newLead.Website = newLead.Website.substring(0, maxSize);
// 		}

// 	//Insert new Lead. If insert throws error, send email with error message in body
// 	try {
// 		insert newLead;
// 		  }
// 	catch (System.exception e) {
// 		 Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
// 		 String[] toAddresses = new String[] {'mchapa@myubiquity.com'};
// 		 mail.setToAddresses(toAddresses);
// 		 mail.setReplyTo('bi@myubiquity.com');
// 		 mail.setSenderDisplayName('Apex Error Message');
// 		 mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
// 		 mail.setPlainTextBody(e.getMessage());
// 		 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
// 				}
// 	  return result;
// 		  }