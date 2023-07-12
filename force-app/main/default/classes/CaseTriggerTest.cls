@isTest public class CaseTriggerTest {
    @isTest static void caseAfterInsertTest() {
        Case testCase = new Case();
        testCase.RecordTypeId = '01237000000EyimAAC';
        insert testCase;
    }
    @isTest static void caseAfterUpdateTest() {
        Case testCaseUpdate = new Case();
        testCaseUpdate.RecordTypeId = '01237000000EyimAAC';
        testCaseUpdate.Status = 'New';
        insert testCaseUpdate;
        testCaseUpdate = [SELECT Id, Status, RecordTypeId FROM Case WHERE Id = :testCaseUpdate.Id];
        testCaseUpdate.Status = 'Jira Comment Sent';
        update testCaseUpdate;
    }
}