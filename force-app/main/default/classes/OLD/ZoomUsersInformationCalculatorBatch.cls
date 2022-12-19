public with sharing class ZoomUsersInformationCalculatorBatch implements Database.Batchable<sObject>{
 
    public Database.QueryLocator start(Database.BatchableContext BC){
        String Query = 'SELECT Id, Name, Zoom_User__c, Zoom_User__r.Email__c, Presence_status__c, Presence_status_time__c, Log_In__c, Log_Out__c FROM Zoom_Info__c WHERE SystemModStamp = TODAY';
        return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext BC, List<Zoom_Info__c> scope){
        List <Zoom_Users_Info__c> result = new List <Zoom_Users_Info__c>();
        
        Map<String, Zoom_Info__c> zMap = new Map<String, Zoom_Info__c>();
        for(Zoom_Info__c inf : scope){
            zMap.put(inf.Zoom_User__r.Email__c, inf);
        }
        
        for(Zoom_Info__c v: scope) {
            Zoom_Users_Info__c zInfo = new Zoom_Users_Info__c();
            // if(v.Presence_status__c == 'Available'){
            //     zInfo.Available__c = 
            // }
            // zInfo.Away__c = 
            // zInfo.Offline__c = 
            // zInfo.User_Log_In__c = 
            // zInfo.User_Log_Out__c = 
            // zInfo.Zoom_User__c  = v.Zoom_User__c;
            // result.add(zInfo);
        }
        upsert result;
    }
    public void finish(Database.BatchableContext BC){
    }
 

}
// Select Id, MIN(Log_In__c), Name, Email__c,(Select Id, Name, Log_In__c From Zoom_Infos__r WHERE SystemModStamp = TODAY) From Zoom_User__c Limit 100

// CAlculating date_time

// Datetime startDate = system.now();// Start date
// Datetime endDate = system.now().addHours(1);//End Date
// integer intDays =  startDate.Date().daysBetween(endDate.Date());
// datetime sameDayEndDate = startDate.addDays(intDays);
// decimal decMinutes = ((endDate.getTime())/1000/60) - ((sameDayEndDate.getTime())/1000/60);
// System.debug('decMinutes '+decMinutes);