public with sharing class ZoomUserInfosRecordCreatorBatchService {

    public static List<ZoomUserInfosRecordCreatorBatchEntity.ZoomUsersProfileWrapper> fetchActivePhoneUsers() {
        String baseUrl = 'callout:ZoomPhone/phone/users';
        Integer pageSize = 50;
        String status = 'activate';
        List<ZoomUserInfosRecordCreatorBatchEntity.ZoomUsersProfileWrapper> userWrappersList = new List<ZoomUserInfosRecordCreatorBatchEntity.ZoomUsersProfileWrapper>();

        String nextPageToken = null;
        Integer totalRecords = 0;

        do {
            String url = baseUrl + '?page_size=' + pageSize + '&status=' + status;
            if (nextPageToken != null) {
                url += '&next_page_token=' + nextPageToken;
            }
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(url);

            Http http = new Http();
            HttpResponse response = http.send(req);

            if (response.getStatusCode() == 200) {
                String json = response.getBody();
                ZoomUserInfosRecordCreatorBatchEntity.ZoomUsersResponseWrapper wrapper = ZoomUserInfosRecordCreatorBatchEntity.parse(json);
                userWrappersList.addAll(wrapper.users);
                totalRecords = wrapper.total_records;
                nextPageToken = wrapper.next_page_token;
            } else {
                System.debug('Callout failed with status code: ' + response.getStatusCode());
                nextPageToken = null;
            }
        } while (nextPageToken != null && userWrappersList.size() < totalRecords && Limits.getCallouts() < Limits.getLimitCallouts());
        return userWrappersList;
    }

    public static Map<String, ZoomUserInfosRecordCreatorBatchEntity.ZoomUsersProfileWrapper> getMapUsersProfiles(){
        List<ZoomUserInfosRecordCreatorBatchEntity.ZoomUsersProfileWrapper> res = fetchActivePhoneUsers();
        Map<String, ZoomUserInfosRecordCreatorBatchEntity.ZoomUsersProfileWrapper> emailToZoomUsersProfileMap = 
            new Map<String, ZoomUserInfosRecordCreatorBatchEntity.ZoomUsersProfileWrapper>();
        for(ZoomUserInfosRecordCreatorBatchEntity.ZoomUsersProfileWrapper user : res){
            emailToZoomUsersProfileMap.put(user.email.toLowerCase(), user);
        }
        return emailToZoomUsersProfileMap;
    }

}
