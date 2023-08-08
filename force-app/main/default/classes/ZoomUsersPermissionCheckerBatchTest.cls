@isTest
public with sharing class ZoomUsersPermissionCheckerBatchTest {

    @isTest
    static void testBatch() {
        User usr = ZoomTestDataFactory.createUser('System Administrator', '@myubiquity.com');
        Test.startTest();
        ZoomUsersPermissionCheckerBatch.start(0);
        ZoomUsersPermissionCheckerBatch.start(007);
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Zoom_Users_Info__c WHERE Email__c LIKE 'testuser%'], 'Zoom_Users_Info__c record should be created');
    }

}