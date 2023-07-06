static final List<String> VALID_STATES = new List<String>{
		'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
};
String zipPattern = '^\\d{5}(?:[-\\s]\\d{4})?$|^\\d{9}$'; // 99999-9999 or 99999
Pattern regex = Pattern.compile(zipPattern);
Lead l = [SELECT Id, Name, Address, Email, Title, Company, Company_FEIN__c, Website, NumberOfEmployees, Description, Industry, Active_of_Employees_in_Relationship__c, Paycor_Client_ID__c, Referrer_s_Email__c, Referral_Info_Last_Name__c,  PaycorEmail__c, LeadSource, LeadSourceDetail__c, Method_of_First_Contact__c, Product_Type__c, OwnerId FROM Lead Where id = '00QDF00000Dklbc2AB'];

String address = '12636 High Bluff Dr, San Diego, California, 12330';
List<String> fullAdd = address.split(', ');
if (fullAdd.size() > 4) {
    String lStreet = fullAdd.size() > 0 ? fullAdd[0].trim() : null;
    String lCity   = fullAdd.size() > 2 ? fullAdd[2].trim() : null;
    String lState  = fullAdd.size() > 3 ? fullAdd[3].trim(): null;
    String lZip    = fullAdd.size() > 4 ? fullAdd[4].trim() : null;
    System.debug('lStreet: ' + lStreet);
    System.debug('lCity: ' + lCity);
    System.debug('lState: ' + lState);
    System.debug('lZip: ' + lZip);
    l.Street = lStreet;
    l.City = lCity;
    l.State = VALID_STATES.contains(lState) ? lState : null;
    l.PostalCode = regex.matcher(lZip).matches() ? lZip : null;
} else if(fullAdd.size() == 4) {
    String lStreet = fullAdd.size() > 0 ? fullAdd[0].trim() : null;
    String lCity = fullAdd.size() > 1 ? fullAdd[1].trim() : null;
    String lState = fullAdd.size() > 2 ? fullAdd[2].trim() : null;
    String lZip = fullAdd.size() > 3 ? fullAdd[3].trim() : null;
    System.debug('else lStreet: ' + lStreet);
    System.debug('else lCity: ' + lCity);
    System.debug('else lState: ' + lState);
    System.debug('else lZip: ' + lZip);
    l.Street = lStreet;
    l.City = lCity;
    l.State = VALID_STATES.contains(lState) ? lState : null;
    l.PostalCode = regex.matcher(lZip).matches() ? lZip : null;
}


