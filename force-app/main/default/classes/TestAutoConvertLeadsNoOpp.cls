@isTest 
      public class TestAutoConvertLeadsNoOpp{
      static testMethod void createnewlead() {
      User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
      
      Test.startTest();    
      Lead leadToCreate =new Lead();
      List<id> Ids= New List<Id>();
      leadToCreate.ownerid= userToCreate.id;
      leadToCreate.LastName ='Gupta';
      leadToCreate.Company='Salesforce';
      leadToCreate.Rating='';
      leadToCreate.Status='Open';
      leadToCreate.Method_of_First_Contact__c='Phone';
      leadToCreate.LeadSource='Direct';
      leadToCreate.LeadSourceDetail__c='Web Lead Form';
      leadToCreate.NumberOfEmployees= 5;
      leadToCreate.Business_Industry__c= 'Accounting';
      leadToCreate.Lead_Origin__c= 'Ubiquity Generated';
      insert leadToCreate;
      
      Ids.add(leadToCreate.id);
      AutoConvertLeadsNoOpp.LeadAssign(Ids);
      
      Test.stopTest();
   }
}