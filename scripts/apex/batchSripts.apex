ZoomUsersPermissionCheckerBatch.start(0);
ZoomUserInfosRecordCreatorBatch.start(007);

ZoomUsersPhoneInfosBatch.start(007);

//delete all zoom users
List<Zoom_Users_Info__c> users= [SELECT Id FROM Zoom_Users_Info__c ];
delete users;

List<Zoom_Phone_Calls_Info__c> calls= [SELECT Id FROM Zoom_Phone_Calls_Info__c];
delete calls;

