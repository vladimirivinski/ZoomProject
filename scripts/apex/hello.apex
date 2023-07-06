
Lead l = [SELECT Id, Name, Address, Email, Title, Company, Company_FEIN__c, Website, NumberOfEmployees, Description, Industry, Active_of_Employees_in_Relationship__c, Paycor_Client_ID__c, Referrer_s_Email__c, Referral_Info_Last_Name__c,  PaycorEmail__c, LeadSource, LeadSourceDetail__c, Method_of_First_Contact__c, Product_Type__c, OwnerId FROM Lead Where id = '00QDF00000Dklbc2AB'];

String CompanyName = 'CompanyName: Test1 Paycor';
String CompanyFEIN = 'CompanyFEIN: 800410000';
String Address = 'Address: 12636 High Bluff Dr, San Diego, California, 12330';
String Website = 'Website: https://www.google.com';
String Employees = 'Employees: 5';
String ActiveOfEmployeesInRelationship = 'ActiveOfEmployeesInRelationship: 5';
String PaycorClientID = 'PaycorClientID: 111181';
String Comments = 'Comments: Please reach out to Jansen';
String ReferredByName = 'Referredby name: Test Man';
String ReferredByEmail = 'Referredby email: test@paycor.com';
String ReferredByPhone = 'Referredby phone: (513) 111-11111';
String ReferredByMobile = 'Referredby mobile: (513) 111-11111';
String ContactName = 'ContactName: Moe Chapa';
String ContactEmail = 'ContactEmail: test@test.com';
String ContactPhone = 'ContactPhone: (888) 11111111';
String ContactTitle = 'ContactTitle: Manager';

List<String> bodyList = new List<String>();
bodyList.add(CompanyName); bodyList.add(CompanyFEIN); bodyList.add(Address); bodyList.add(Website); bodyList.add(Employees); bodyList.add(ActiveOfEmployeesInRelationship); bodyList.add(PaycorClientID); bodyList.add(Comments); bodyList.add(ReferredByName); bodyList.add(ReferredByEmail); bodyList.add(ReferredByPhone); bodyList.add(ReferredByMobile); bodyList.add(ContactName); bodyList.add(ContactEmail); bodyList.add(ContactPhone); bodyList.add(ContactTitle);


Map<String, String> bodyMap= new Map<String, String>();

for(String body : bodyList){
    List<String> bodySplit = body.split(':');
    String key   = body.substringBefore(':').trim();
    String value = body.substringAfter(':').trim();
    System.debug('key |'+key);
    System.debug('value |'+value);
    System.debug('-------------------------------------------');
    System.debug('bodySplit key|'+bodySplit[0]);
    System.debug('bodySplit val|'+bodySplit[1]);
    // bodyMap.put(bodySplit[0], bodySplit[1]);
}
static final List<String> VALID_STATES = new List<String>{
		'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
	};

String htmlBodyEmail = '<p>CompanyName: Test1 Paycor </p>'+
                       '<p>CompanyFEIN: 800410000 </p>' +
                       '<p>Address: 12636 High Bluff Dr, San Diego, California, 12330 </p>' +
                       '<p>Website: https://www.google.com </p>' +
                       '<p>Employees: 5 </p>' +
                       '<p>ActiveOfEmployeesInRelationship: 5 </p>' +
                       '<p>PaycorClientID: 111181 </p>' +
                       '<p>Comments: Please reach out to Jansen </p>' +
                       '<p>Referredby name: Test Man </p>' +
                       '<p>Referredby email: test@paycor.com </p>' +
                       '<p>Referredby phone: (513) 111-11111 </p>' +
                       '<p>Referredby mobile: (513) 111-11111 </p>' +
                       '<p>ContactName: Moe Chapa </p>' +
                       '<p>ContactEmail: test@test.com </p>' +
                       '<p>ContactPhone: (888) 11111111 </p>' +
                       '<p>ContactTitle: Manager </p>';

		// String htmlBodyEmail = email.htmlBody;
        Map<String, String> inboundHtmlFieldsValueMap = new Map<String, String>();
        if(htmlBodyEmail != null && htmlBodyEmail != ''){
            String unescapedHtmlBody = htmlBodyEmail.unescapeHtml4();
            String clearString = unescapedHtmlBody.replaceAll('=0A=', '');
            List<String> splitedEmailHtml = clearString.split('</p>');
            inboundHtmlFieldsValueMap = parseEmailBody(splitedEmailHtml);
        }

        createLeadFromPaycorEmail(inboundHtmlFieldsValueMap, htmlBodyEmail);



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
				String firstName = fullName.size() > 0 ? fullName[0] : null;
				String lastName  = fullName.size() > 1 ? fullName[1] : value;
				newLead.FirstName = firstName.trim();
				newLead.LastName  = String.isNotBlank(lastName) ? lastName.trim() : null;
			}
			if (key == address) {
				List<String> fullAdd = value.split(', ');
                if(fullAdd.size() == 5){
					String lStreet      = fullAdd.size() > 0 ? fullAdd[0].trim() : null;
					String lCity        = fullAdd.size() > 2 ? fullAdd[2].trim() : null;
					String lState       = fullAdd.size() > 3 ? fullAdd[3].trim(): null;
					String lZip         = fullAdd.size() > 4 ? fullAdd[4].trim() : null;
					newLead.Street      = lStreet;
					newLead.City        = lCity;
					newLead.State       = VALID_STATES.contains(lState) ? lState : null;
					newLead.PostalCode  = regex.matcher(lZip).matches() ? lZip : null;
                } else if(fullAdd.size() == 4){
					String lStreet      = fullAdd.size() > 0 ? fullAdd[0].trim() : null;
					String lCity        = fullAdd.size() > 1 ? fullAdd[1].trim() : null;
					String lState       = fullAdd.size() > 2 ? fullAdd[2].trim() : null;
					String lZip         = fullAdd.size() > 3 ? fullAdd[3].trim() : null;
					newLead.Street      = lStreet;
					newLead.City        = lCity;
					newLead.State       = VALID_STATES.contains(lState) ? lState : null;
					newLead.PostalCode  = regex.matcher(lZip).matches() ? lZip : null;
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
                newLead.Description = value.trim();
            }
			if (key == industry){
                newLead.Industry = String.isNotBlank(value) ? value : null;
            }
			if (key == activeNumberOfEmployees){
                String val = value.trim();
                newLead.Active_of_Employees_In_Relationship__c = String.isNotBlank(val) && val.isNumeric() ? Integer.valueOf(val) : 0;
            }
			if (key == paycorClientID){
                newLead.Paycor_Client_ID__c = value.trim();
            }
			if (key == referredByEmail){
                Matcher reffEmailMatcher = emailPattern.matcher(value);
                newLead.Referrer_s_Email__c = reffEmailMatcher.matches() ? value.trim() : null;
            }
			if (key == referredByName){
				List<String> splitedName = value.split(' ');
				String lstName  = splitedName.size() > 1 ? splitedName[1] : value.trim();
				newLead.Referral_Info_Last_Name__c  = String.isNotBlank(lstName) ? lstName.trim() : null;
            }
		}
		if (String.isBlank(newLead.LastName)) {
			newLead.LastName = 'Paycor Lead';
		}
        if (String.isBlank(newLead.Company)) {
			newLead.Company = 'Unknown Company';
		}
        newLead.LeadSource = 'HCM';
        newLead.LeadSourceDetail__c = 'Paycor';
        newLead.Method_of_First_Contact__c = 'Partner Referral';
        newLead.Product_Type__c = '401(k)';
        newLead.OwnerId = '00G37000000ksAD';
        newLead.PaycorEmail__c = htmlBodyEmail;
			insert newLead;

	}