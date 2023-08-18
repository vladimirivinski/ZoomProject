public with sharing class ZoomUserInfosRecordCreatorBatchService {

    public static List<ZoomUserInfosRecordCreatorBatchEntity.UsersProfWrapper> fetchActivePhoneUsers() {
        String baseUrl = 'callout:ZoomPhone/phone/users';
        Integer pageSize = 100;
        String status = 'activate';
        List<ZoomUserInfosRecordCreatorBatchEntity.UsersProfWrapper> userWrappersList = new List<ZoomUserInfosRecordCreatorBatchEntity.UsersProfWrapper>();

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
                ZoomUserInfosRecordCreatorBatchEntity.UserResponseWrapper wrapper = ZoomUserInfosRecordCreatorBatchEntity.parse(json);
                userWrappersList.addAll(wrapper.users);
                totalRecords = wrapper.total_records;
                nextPageToken = wrapper.next_page_token;
            } else {
                System.debug('Callout failed with status code: ' + response.getStatusCode());
                nextPageToken = null;
            }
        } while (nextPageToken != null && userWrappersList.size() < totalRecords);
        return userWrappersList;
    }

    public static Map<String, ZoomUserInfosRecordCreatorBatchEntity.UsersProfWrapper> getMapUsersProfiles(){
        List<ZoomUserInfosRecordCreatorBatchEntity.UsersProfWrapper> lst = fetchActivePhoneUsers();
        Map<String, ZoomUserInfosRecordCreatorBatchEntity.UsersProfWrapper> emailToZoomUsersProfileMap =
            new Map<String, ZoomUserInfosRecordCreatorBatchEntity.UsersProfWrapper>();

        if(lst != null && !lst.isEmpty()){
            for(ZoomUserInfosRecordCreatorBatchEntity.UsersProfWrapper obj : lst){
                String email = obj.email.toLowerCase().trim();
                emailToZoomUsersProfileMap.put(email, obj);
            }
            return emailToZoomUsersProfileMap;
        }
        return null;
}




}