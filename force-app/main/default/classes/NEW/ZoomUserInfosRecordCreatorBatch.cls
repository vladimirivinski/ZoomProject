public with sharing class ZoomUserInfosRecordCreatorBatch implements Database.Batchable<sObject>, schedulable {
    public Database.QueryLocator start(Database.BatchableContext bc){
        // NOTE: Retrieve Active users from org 
        // String query = 'SELECT Id, Name, Email FROM User WHERE isActive = true  AND Email LIKE \'%@myubiquity.com%\'';
        String query = 'SELECT Id, Name, Email FROM User WHERE isActive = true AND CallCenterId != null AND (Email LIKE \'%@myubiquity.com%\' OR Email = \'mchapa@myubiquity.com\')';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<User> scope){
        List<Zoom_Users_Info__c> result = new List <Zoom_Users_Info__c>();
            for(User u: scope) {
                Zoom_Users_Info__c rec = new Zoom_Users_Info__c();
                rec.User__c  = u.id;
                rec.Email__c = u.Email.substringBefore('.invalid'); // NOTE: substring used for devorg!!!
                rec.Name = u.Name;
                rec.Presence_Status__c = 'Initial';
                System.debug('<<<<<<<<<<<<<<<<<<<< Datetime.Now() >>>>>>>>>>>>>>>>>>>>>>>>> \n ' + Datetime.Now());
                System.debug('<<<<<<<<<<<<<<<<<<<< Date.today() >>>>>>>>>>>>>>>>>>>>>>>>> \n ' + Date.today());
                rec.Status_Updated__c =  Datetime.Now();    // ????????? CONVERT TO PST ??????????
                rec.Tracking_Date__c =   Date.today();      // ????????? CONVERT TO PST ??????????
                rec.Available__c = 0;
                rec.Away__c = 0;
                rec.In_Calendar_Event__c = 0;
                rec.In_Meeting__c = 0;
                rec.Offline__c = 0;
                rec.On_Phone_Call__c = 0;
                rec.Presenting__c = 0;
                rec.Do_Not_Disturb__c = 0;
                result.add(rec);
            }
        insert result;
    }
    public void finish(Database.BatchableContext bc){}

    //NOTE: Schedule interface
    public static void start(Integer hour){
        string jobName = 'Zoom Users Info Create Records';
        if (hour == 007) Database.executeBatch(new ZoomUserInfosRecordCreatorBatch(), 50);
        else{
            jobName = jobName += ' - ' + datetime.now().format();
            String cron = '0 0 ' + string.valueof(hour) + ' ? * MON-FRI'; // NOTE: Execute From Monday - Friday 
            system.schedule(jobName, cron, new ZoomUserInfosRecordCreatorBatch());
        }
    }

    public void execute(SchedulableContext SC) {
        database.executeBatch(new ZoomUserInfosRecordCreatorBatch(), 50);
    }
}
// EXECUTE SCHEDULE 
// immediately submits the batch job - 007 param just a JOKE!!!
//ZoomUserInfosRecordCreatorBatch.start(007);

// schedules the batch job to run nightly at 0am. - FROM 0 to 23
// ZoomUserInfosRecordCreatorBatch.start(0);

