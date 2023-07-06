global class PaycorEmailHandler2 implements Messaging.InboundEmailHandler {
	global static final List<String> VALID_STATES = new List<String>{
		'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
	};

	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		String htmlBodyEmail = email.htmlBody;
		String unescapedHtmlBody = htmlBodyEmail.unescapeHtml4();
		List<String> splitedEmailHtml = unescapedHtmlBody.split('</p>');
		String emailPlainTextBody = email.plainTextBody;
		String clearStr = emailPlainTextBody.replaceAll('<[^>]+>', '');
		List<String> splitedEmailText = clearStr.split('\n');
		Map<String, String> inboundHtmlFieldsValueMap = PaycorEmailHandler2.parseEmailBody(splitedEmailHtml);
		Map<String, String> inboundTextFieldsValueMap = PaycorEmailHandler2.parseEmailBody(splitedEmailText);
		Map<String, String> inboundFieldsValueMap = inboundHtmlFieldsValueMap.size() > inboundTextFieldsValueMap.size() ? inboundHtmlFieldsValueMap : inboundTextFieldsValueMap;
        PaycorEmailHandler2.createLeadFromPaycorEmail(inboundFieldsValueMap, htmlBodyEmail, emailPlainTextBody);
		return null;
	}

	private static Map<String, String> parseEmailBody(List<String> splitedList){
		Map<String, String> inboundFieldsValueMap = new Map<String, String>();
		for (String s : splitedList){
			String unescaped = s.unescapeHtml4();
			String clearStr = s.replaceAll('<[^>]+>', '');
			if (s.contains(':')){
				String key = clearStr.substringBefore(':').trim();
				String value = clearStr.substringAfter(':').trim();
				inboundFieldsValueMap.put(key, value);
			}
		}
		return inboundFieldsValueMap;
	}

	private static void createLeadFromPaycorEmail(Map<String, String> inboundFieldsValueMap, String htmlBodyEmail, String emailPlainTextBody) {
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
				} else {
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
                newLead.Company = value;
            }
			if (key == companyFEIN){
                newLead.Company_FEIN__c = value.length() < 9 ? value.trim() : value.substring(0, 9);
            }
			if (key == website){
                newLead.Website = value.length() < 255 ? String.valueof(value) : null;
            }
			if (key == employees){
                newLead.NumberOfEmployees = String.isNotBlank(value) ? Integer.valueof(value.replace(',', '')) : 0;
            }
			if (key == comments){
                newLead.Description = value;
            }
			if (key == industry){
                newLead.Industry = String.isNotBlank(value) ? value : null;
            }
			if (key == activeNumberOfEmployees){
                value.trim();
                newLead.Active_of_Employees_In_Relationship__c = 0;
                // newLead.Active_of_Employees_In_Relationship__c = String.isNotBlank(value) ? integer.valueof(value) : 0;
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
            if (newLead.LastName == null || newLead.LastName == ' ' || String.isBlank(newLead.LastName)) {
                newLead.LastName = 'Paycor Lead';
            }
            if (newLead.Company == null || newLead.Company == ' ' || String.isBlank(newLead.Company)) {
                newLead.Company = 'Unknown Company';
            }
		}

        newLead.LeadSource = 'HCM';
        newLead.LeadSourceDetail__c = 'Paycor';
        newLead.Method_of_First_Contact__c = 'Partner Referral';
        newLead.Product_Type__c = '401(k)';
        newLead.OwnerId = '00G37000000ksAD';
        newLead.PaycorEmail__c = emailPlainTextBody;
		try {
			insert newLead;
		} catch (System.exception e) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<String> toAddresses = new List<String>{'moe.chapa.test@gmail.com'};
			mail.setToAddresses(toAddresses);
			mail.setReplyTo('moe.chapa.test@gmail.com');
			mail.setSenderDisplayName('Apex Error Message - PaycorEmailHandler2.createLeadFromPaycorEmail()');
			mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
			mail.setPlainTextBody(e.getMessage() + '\n' + emailPlainTextBody + '\n' + htmlBodyEmail);
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
		}
	}
}
