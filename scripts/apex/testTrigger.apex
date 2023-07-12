List<Test_Object__c> testLSt = new List<Test_Object__c>();
for(Integer i=0;i<1000;i++){
    Test_Object__c testObj = new Test_Object__c();
    testObj.Name = 'Test'+i;
    testObj.Some_Field__c = 'Some Field ' + i;
    testObj.Check_Field__c = true;
    testLSt.add(testObj);
}
insert testLSt;

List<Test_Object__c> updList = [SELECT Id, Name, Some_Field__c, Check_Field__c, Update_Field__c FROM Test_Object__c];
for(Test_Object__c testObj : updList){
    testObj.Update_Field__c = 'Update Field ' + testObj.Name;
}
update updList;


List<Test_Object__c> delLst = [SELECT Id, Name, Some_Field__c, Check_Field__c, Update_Field__c FROM Test_Object__c];
delete delLst;