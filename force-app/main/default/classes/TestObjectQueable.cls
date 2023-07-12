public with sharing class TestObjectQueable implements Queueable, Database.AllowsCallouts {

    private List<Id> propsLst;
    public TestObjectQueable(List<Id> propsLst){
    	this.propsLst = propsLst;
    }

    public void execute(QueueableContext context) {
        System.debug('propsLst SIZE: ' + propsLst.size());
        List<Test_Object__c> lstObj = [SELECT Id, Name, Some_Field__c, Check_Field__c, Update_Field__c FROM Test_Object__c WHERE Id IN :propsLst];
        System.debug('*******lstObj.size(): ' + lstObj.size());
        System.debug('*******lstObj: \n' + lstObj);
        Integer numAuth = 0;
        System.debug('*******Auhtentication Callout: ' + numAuth+1);
        Integer num = 0;
        Integer ins = 0;
        Integer upd = 0;

        for(Id i: propsLst){
            System.debug('++++TestObjectQueable.execute() \n' + i);
            System.debug('++++POST Callout: ' + num +1);
            System.debug('++++insert: ' + ins +1);
            System.debug('++++update: ' + upd +1);
        }
    }
}