@isTest
private with sharing class ZoomUserInfosRecordCreatorBatchTest {
    @isTest
    static void batchCreatorTest() {
        User usr = ZoomTestDataFactory.createUser('System Administrator', '@myubiquity.com');
        Test.startTest();
        ZoomUserInfosRecordCreatorBatch batch = new ZoomUserInfosRecordCreatorBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Zoom_Users_Info__c WHERE Email__c LIKE 'testuser%'], 'Zoom_Users_Info__c record should be created');
    }
    @isTest
    static void schedulerTest(){
        User usr = ZoomTestDataFactory.createUser('System Administrator', '@myubiquity.com');
        Test.startTest();
        ZoomUserInfosRecordCreatorBatch.start(007);
        ZoomUserInfosRecordCreatorBatch.start(1);
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Zoom_Users_Info__c WHERE Email__c LIKE 'testuser%'], 'Zoom_Users_Info__c record should be created');
        System.assertEquals(1, [SELECT COUNT() FROM Zoom_Users_Info__c WHERE Email__c LIKE 'testuser%'], 'Zoom_Users_Info__c record should be created');
    }
}