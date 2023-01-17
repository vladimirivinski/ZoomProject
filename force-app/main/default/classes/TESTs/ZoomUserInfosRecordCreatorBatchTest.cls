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
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        ZoomUserInfosRecordCreatorBatch batch = new ZoomUserInfosRecordCreatorBatch();
        System.schedule('ScheduledApexTest', CRON_EXP, batch);
        Test.stopTest();
    }
}
