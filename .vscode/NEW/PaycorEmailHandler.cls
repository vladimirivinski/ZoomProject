global class PaycorEmailHandler implements Messaging.InboundEmailHandler {

    global static List<String> VALID_STATES = new List<String>{'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming'};

	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        //Injests contents of emails sent from Email Service address
  		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        //Initializes relevant strings to be used in Class
        String body = '', subject = '', emailAddress='', failedDML='', label = '', value = '', value2 = '';
		Lead newLead    = new Lead();
        //Maps body of email to String
	    body 			= email.plainTextBody;
        Integer maxSize = 255;

        if(body != Null && body != ''){
            System.debug('======body======= \n' + body );
            //Separate body of email into separate strings, broken by line breaks in the text
            String[] emailBodyRows = body.split('\n');
            System.debug(' emailBodyRows  : \n' + emailBodyRows );
//===================================================================================================
//===================================================================================================
            List<String> normolizedEmailBodyRows = new List<String>();
            
            for(String line : emailBodyRows) {
                if(normolizedEmailBodyRows.isEmpty() && !line.contains(':') || line.contains(':')){
                    normolizedEmailBodyRows.add(line.trim());
                } else if (!line.contains(':')) {
                    Integer lastIndex = normolizedEmailBodyRows.size() -1;
                    normolizedEmailBodyRows[lastIndex] = normolizedEmailBodyRows[lastIndex] + ' ' + line.trim();
                }
            }
//===================================================================================================
//===================================================================================================
            for (String bodyRow :normolizedEmailBodyRows) {
                //Iterate over list of email body strings
                if(bodyRow.contains(':')){
                    //Separate each row at the colon if found. Anything left of the colon is the label, anything to the right is each label's value
                	String[] rowContents = bodyRow.split(':');
                        label  = rowContents.size() > 0 ? rowContents[0].trim(): bodyRow;
                        value  = rowContents.size() > 1 ? rowContents[1].trim(): bodyRow;
                        value2 = rowContents.size() > 2 ? rowContents[2].trim(): bodyRow;
                        switch on label {
                            //for each label, add associated value to new Lead
                            when 'Contact Name' {
                                String[] fullName 								    = value.split(' ');
                                String firstName  								    = fullName.size() > 0 ? fullName[0] : value;
                                String lastName   								    = fullName.size() > 1 ? fullName[1] : value;
                                newLead.FirstName 								    = firstName;
                                newLead.LastName  								    = lastName;
                                }	
                            when 'Address' {
                                String[] fullAdd   								    = value.split(',');
                                if(fullAdd.size() > 4){
                                	String lStreet 	   								= fullAdd.size() > 0 ? fullAdd[0] : value;
                                	String lCity 	  								= fullAdd.size() > 2 ? fullAdd[2] : value;
                                	String lState 	   								= fullAdd.size() > 3 ? fullAdd[3] : value;


                                	String lZip 	   								 = fullAdd.size() > 4 ? fullAdd[4] : value;
                                	newLead.Street 	   								 = lStreet;
                                	newLead.City 	   								 = lCity;
                                	newLead.State 	   								 = VALID_STATES.contains(lState.trim()) ? lState.trim() : null;
                                	newLead.PostalCode 								 = lZip;   
                                }
                                else{
                                    String lStreet 	   								 = fullAdd.size() > 0 ? fullAdd[0] : value;
                                    String lCity 	  								 = fullAdd.size() > 1 ? fullAdd[1] : value;
                                    String lState 	   								 = fullAdd.size() > 2 ? fullAdd[2] : value;
                                    String lZip 	   								 = fullAdd.size() > 3 ? fullAdd[3] : value;
                                    newLead.Street 	   								 = lStreet;
                                    newLead.City 	   								 = lCity;
                                    newLead.State 	   								 = VALID_STATES.contains(lState.trim()) ? lState.trim() : null;
                                    newLead.PostalCode 								 = lZip;
                                }
                            }
                            when 'Contact Email' {
                                newLead.email 									    = String.valueof(value.replace('<mailto',''));
                            }
                            when 'Contact Phone' {
                                newLead.Phone 									    = value;
                            }
                            when 'Contact Title' {		  
                                newLead.Title 										= value;
                            }
                            when 'Company Name' {
                                    newLead.Company 								= value;
                                System.debug(newLead.Company);
                            }
                            when 'Company FEIN' {
                                newLead.Company_FEIN__c 							= value;
                            }
                            when 'Website' {
                                if(value == 'https' || value == 'http'){
                                    newLead.Website 								= String.valueof(value + value2);
                                }
                                else{
                                    newLead.Website 								= value;
                                }
                            }
                            when 'Employees' {
                                if(!String.isBlank(value)){
                                    newLead.NumberOfEmployees 				    	= integer.valueof(value.replace(',', ''));
                                }
                                else{
                                	newLead.NumberOfEmployees 						= 0;
                            	}
                            }
                            when 'Comments' {
                                newLead.Lead_Notes__c 								= value;
                            }
                            when 'Industry' {
                                newLead.Industry 									= value;
                            }
                            when 'Active # of Employees In Relationship'{
                                if(!String.isBlank(value)){
                                    String[] spaceSaver = value.split(' ');
                                    newLead.Active_of_Employees_In_Relationship__c  = integer.valueof(spaceSaver[0].replace(',', ''));
                                    newLead.Paycor_Client_ID__c 					= value2;
                                }
                                else{
                                    newLead.Active_of_Employees_In_Relationship__c  = 0;
                                }
                            }
                            when 'Paycor Client ID' {
                                newLead.Paycor_Client_ID__c 						= value;
                            }
                            when 'Referred by email' {
                                newLead.Referrer_s_Email__c 						= String.valueof(value.replace('<mailto',''));
                            }
                            when 'Referred by name' {
                                newLead.Referral_Info_Last_Name__c 					= value;
                            } 
                        }
                    }
                }
            }
        //Assign default values to required fields if labels are not found above
        if(newLead.LastName == null || newLead.LastName == ' ' || String.isBlank(newLead.LastName)){
            newLead.LastName 				   = 'Paycor Lead';
        }
        if(newLead.Company == null || newLead.Company == ' ' || String.isBlank(newLead.Company)){
            newLead.Company 				   = 'Unknown Company';
        }
        	//Assign defaults required for every Paycor sourced Lead
            newLead.LeadSource 				   = 'HCM';
            newLead.LeadSourceDetail__c 	   = 'Paycor';
            newLead.Method_of_First_Contact__c = 'Partner Referral';
            newLead.Product_Type__c 		   = '401(k)';
        	newLead.OwnerId         		   = '00G37000000ksAD';
            
        	//Trim website values if received value is too large
            if(newLead.Website != null && newLead.Website.length() > maxSize){
                newLead.Website = newLead.Website.substring(0, maxSize);
            }
        
        //Insert new Lead. If insert throws error, send email with error message in body
        try {
	    	insert newLead;          
      		} 
        catch (System.exception e) {
             Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
             String[] toAddresses = new String[] {'mchapa@myubiquity.com'};
             mail.setToAddresses(toAddresses);
             mail.setReplyTo('mchapa@myubiquity.com');
             mail.setSenderDisplayName('Apex Error Message');
             mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
             mail.setPlainTextBody(e.getMessage());
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    } 
      	return result;
  			}
}


// String body = 'Paycor has referred a new lead to Ubiquity.\nReferred by name: Jessica Green\nReferred by email: jgreen@paycor.com<mailto:jgreen@paycor.com>\nReferred by phone: (513) 279-3674\nReferred by mobile:\nCompany Name: Interior Decisions INC.\nCompany FEIN: 201076129\nPhone: 5617627600\nAddress: 602 W Lantana Road \nSuite B, Lantana, Florida, 33462\nWebsite: iconikcd.com\nIndustry: Construction\nEmployees: 3\nActive # of Employees In Relationship: 3 Paycor Client ID: 159733 Account Record ID: 0016S00003Jdxq7\nComments:\n';

// String body = 'Paycor has referred a new lead to Ubiquity.\nReferred by name: Jessica Green\nReferred by email: jgreen@paycor.com<mailto:jgreen@paycor.com>\nReferred by phone: (513) 279-3674\nReferred by mobile:\nCompany Name: Interior Decisions INC.\nCompany FEIN: 201076129\nPhone: 5617627600\nAddress: 602 W Lantana Road \nSuite B, Lantana, Florida, 33462\nWebsite: iconikcd.com\nIndustry: Construction\nEmployees: 3\nActive # of Employees In Relationship: 3 Paycor Client ID: 159733 Account Record ID: 0016S00003Jdxq7\nComments:\n';
// System.debug('body \n' + body);

// List<String> emailBodyRows = body.split('\n');
// System.debug('emailBodyRows \n' + emailBodyRows);

// List<String> normLst = new List<String>();

// for(String line : emailBodyRows) {
// 	if(normLst.isEmpty() && !line.contains(':') || line.contains(':')){
//         normLst.add(line.trim());
//     } else if (!line.contains(':')) {
//         Integer lastIndex = normLst.size() -1;
//         normLst[lastIndex] = normLst[lastIndex] + ' ' + line.trim();
//     }
// }

           

// List<String> VALID_STATES = new List<String>{'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming'};



// 'Alabama','AL','Alaska','AK','Arizona','AZ','Arkansas','AR','California','CA','Colorado','CO','Connecticut','CT','Delaware','DE','Florida','FL','Georgia','GA','Hawaii','HI','Idaho','ID','Illinois','IL','Indiana','IN','Iowa','IA','Kansas','KS','Kentucky','KY','Louisiana','LA','Maine','ME','Maryland','MD','Massachusetts','MA','Michigan','MI','Minnesota','MN','Mississippi','MS','Missouri','MO','Montana','MT','Nebraska','NE','Nevada','NV','New Hampshire','NH','New Jersey','NJ','New Mexico','NM','New York','NY','North Carolina','NC','North Dakota','ND','Ohio','OH','Oklahoma','OK','Oregon','OR','Pennsylvania','PA','Rhode Island','RI','South Carolina','SC','South Dakota','SD','Tennessee','TN','Texas','TX','Utah','UT','Vermont','VT','Virginia','VA','Washington','WA','West Virginia','WV','Wisconsin','WI','Wyoming', 'WY'




// Paycor has referred a new lead to Ubiquity.
// Referred by name: Test Test
// Referred by email: jtest@paycor.com<mailto:jtest@paycor.com>
// Referred by phone: (513) 1111111
// Referred by mobile:
// Company Name: Test INC.
// Company FEIN: 121212121
// Phone: 1234567800
// Address: 102 Test Road
// Suite B, Test, Mississippi, 33333
// Website: itest.com
// Industry: Construction
// Employees: 5
// Active # of Employees In Relationship: 3 Paycor Client ID: 123456 Account Record ID: 0011S00000xxxx7
// Comments:
// Contact Name: Test User
// Contact Email: testemail@test.com<mailto:testemail@test.com>
// Contact Phone: (561) 1111-2211
// Contact Title: test





// global class PaycorEmailHandler implements Messaging.InboundEmailHandler {
// 	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
//         //Injests contents of emails sent from Email Service address
//   		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
//         //Initializes relevant strings to be used in Class
//         String body = '', subject = '', emailAddress='', failedDML='', label = '', value = '', value2 = '';
// 		Lead newLead    = new Lead();
//         //Maps body of email to String
// 	    body 			= email.plainTextBody;
//         Integer maxSize = 255;

//         if(body != Null && body != ''){
//             //Separate body of email into separate strings, broken by line breaks in the text
//             String[] emailBodyRows = body.split('\n');
//             for (String bodyRow:emailBodyRows) {
//                 //Iterate over list of email body strings
//                 if(bodyRow.contains(':')){
//                     //Separate each row at the colon if found. Anything left of the colon is the label, anything to the right is each label's value
//                 	String[] rowContents = bodyRow.split(':');
//                         label  = rowContents.size() > 0 ? rowContents[0].trim(): bodyRow;
//                         value  = rowContents.size() > 1 ? rowContents[1].trim(): bodyRow;
//                         value2 = rowContents.size() > 2 ? rowContents[2].trim(): bodyRow;
//                         switch on label {
//                             //for each label, add associated value to new Lead
//                             when 'Contact Name' {
//                                 String[] fullName 								    = value.split(' ');
//                                 String firstName  								    = fullName.size() > 0 ? fullName[0] : value;
//                                 String lastName   								    = fullName.size() > 1 ? fullName[1] : value;
//                                 newLead.FirstName 								    = firstName;
//                                 newLead.LastName  								    = lastName;
//                                 }	
//                             when 'Address' {
//                                 String[] fullAdd   								    = value.split(',');
//                                 if(fullAdd.size() > 4){
//                                 	String lStreet 	   								    = fullAdd.size() > 0 ? fullAdd[0] : value;
//                                 	String lCity 	  								    = fullAdd.size() > 2 ? fullAdd[2] : value;
//                                 	String lState 	   								    = fullAdd.size() > 3 ? fullAdd[3] : value;
//                                 	String lZip 	   								    = fullAdd.size() > 4 ? fullAdd[4] : value;
//                                 	newLead.Street 	   								    = lStreet;
//                                 	newLead.City 	   								    = lCity;
//                                 	newLead.State 	   								    = lState;
//                                 	newLead.PostalCode 								    = lZip;   
//                                 }
//                                 else{
//                                     String lStreet 	   								    = fullAdd.size() > 0 ? fullAdd[0] : value;
//                                     String lCity 	  								    = fullAdd.size() > 1 ? fullAdd[1] : value;
//                                     String lState 	   								    = fullAdd.size() > 2 ? fullAdd[2] : value;
//                                     String lZip 	   								    = fullAdd.size() > 3 ? fullAdd[3] : value;
//                                     newLead.Street 	   								    = lStreet;
//                                     newLead.City 	   								    = lCity;
//                                     newLead.State 	   								    = lState;
//                                     newLead.PostalCode 								    = lZip;
//                                 }
//                             }
//                             when 'Contact Email' {
//                                 newLead.email 									    = String.valueof(value.replace('<mailto',''));
//                             }
//                             when 'Contact Phone' {
//                                 newLead.Phone 									    = value;
//                             }
//                             when 'Contact Title' {		  
//                                 newLead.Title 										= value;
//                             }
//                             when 'Company Name' {
//                                     newLead.Company 								= value;
//                                 System.debug(newLead.Company);
//                             }
//                             when 'Company FEIN' {
//                                 newLead.Company_FEIN__c 							= value;
//                             }
//                             when 'Website' {
//                                 if(value == 'https' || value == 'http'){
//                                     newLead.Website 								= String.valueof(value + value2);
//                                 }
//                                 else{
//                                     newLead.Website 								= value;
//                                 }
//                             }
//                             when 'Employees' {
//                                 if(!String.isBlank(value)){
//                                     newLead.NumberOfEmployees 				    	= integer.valueof(value.replace(',', ''));
//                                 }
//                                 else{
//                                 	newLead.NumberOfEmployees 						= 0;
//                             	}
//                             }
//                             when 'Comments' {
//                                 newLead.Lead_Notes__c 								= value;
//                             }
//                             when 'Industry' {
//                                 newLead.Industry 									= value;
//                             }
//                             when 'Active # of Employees In Relationship'{
//                                 if(!String.isBlank(value)){
//                                     String[] spaceSaver = value.split(' ');
//                                     newLead.Active_of_Employees_In_Relationship__c  = integer.valueof(spaceSaver[0].replace(',', ''));
//                                     newLead.Paycor_Client_ID__c 					= value2;
//                                 }
//                                 else{
//                                     newLead.Active_of_Employees_In_Relationship__c  = 0;
//                                 }
//                             }
//                             when 'Paycor Client ID' {
//                                 newLead.Paycor_Client_ID__c 						= value;
//                             }
//                             when 'Referred by email' {
//                                 newLead.Referrer_s_Email__c 						= String.valueof(value.replace('<mailto',''));
//                             }
//                             when 'Referred by name' {
//                                 newLead.Referral_Info_Last_Name__c 					= value;
//                             } 
//                         }
//                     }
//                 }
//             }
//         //Assign default values to required fields if labels are not found above
//         if(newLead.LastName == null || newLead.LastName == ' ' || String.isBlank(newLead.LastName)){
//             newLead.LastName 				   = 'Paycor Lead';
//         }
//         if(newLead.Company == null || newLead.Company == ' ' || String.isBlank(newLead.Company)){
//             newLead.Company 				   = 'Unknown Company';
//         }
//         	//Assign defaults required for every Paycor sourced Lead
//             newLead.LeadSource 				   = 'HCM';
//             newLead.LeadSourceDetail__c 	   = 'Paycor';
//             newLead.Method_of_First_Contact__c = 'Partner Referral';
//             newLead.Product_Type__c 		   = '401(k)';
//         	newLead.OwnerId         		   = '00G37000000ksAD';
            
//         	//Trim website values if received value is too large
//             if(newLead.Website != null && newLead.Website.length() > maxSize){
//                 newLead.Website = newLead.Website.substring(0, maxSize);
//             }
        
//         //Insert new Lead. If insert throws error, send email with error message in body
//         try {
// 	    	insert newLead;          
//       		} 
//         catch (System.exception e) {
//              Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
//              String[] toAddresses = new String[] {'bi@myubiquity.com'};
//              mail.setToAddresses(toAddresses);
//              mail.setReplyTo('bi@myubiquity.com');
//              mail.setSenderDisplayName('Apex Error Message');
//              mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
//              mail.setPlainTextBody(e.getMessage());
//              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
//                     } 
//       	return result;
//   			}
// }