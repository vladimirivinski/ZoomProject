ZoomUsersPermissionCheckerBatch.start(0);
ZoomUserInfosRecordCreatorBatch.start(007);

ZoomUsersPhoneInfosBatch.start(007);

//delete all zoom users
List<Zoom_Users_Info__c> zusrs= [SELECT Id FROM Zoom_Users_Info__c ];
delete zusrs;