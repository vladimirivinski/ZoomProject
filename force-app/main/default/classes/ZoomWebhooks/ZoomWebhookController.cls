public without sharing class ZoomWebhookController {
	static final String PRESENCE_STATUS = 'user.presence_status_updated';
	static final String USER_SIGNED_IN = 'user.signed_in';
	static final String USER_SIGNED_OUT = 'user.signed_out';

	static final String CONTACT_CENTER_USER_LOGIN = 'contact_center.user_login';
	static final String CONTACT_CENTER_USER_LOGOUT = 'contact_center.user_logout';
	static final String CONTACT_CENTER_USER_STATUS_CHANGED = 'contact_center.user_status_changed';


	public static void checkZoomEvent(Map<String, Object> resp) {
		String jsonString = JSON.serialize(resp);
		ZoomWebhookHelper.ResponseWrapper wrapper = ZoomWebhookHelper.populateWrapper(jsonString);
		System.debug('resp====' + resp);
		System.debug('wrapper::::::::: ' + wrapper);
		String event            = wrapper.event;
		String email            = wrapper.payload.obj.email;
		String ccEmail          = wrapper.payload.obj.user_email;
		String status           = wrapper.payload.obj.presence_status;
		String ccStatus         = wrapper.payload.obj.current_status_name;
		String ccSubStatus      = wrapper.payload.obj.current_sub_status_name;
		String ccPrevStatus     = wrapper.payload.obj.previous_status_name;
		String ccPrevSubStatus  = wrapper.payload.obj.previous_sub_status_name;
		DateTime lastChanged    = wrapper.payload.obj.date_time;

		if (event == PRESENCE_STATUS) {
			ZoomWebhookHelper.presenceStatusUpdated(email, status, lastChanged);
		} else if (event == USER_SIGNED_IN || event == USER_SIGNED_OUT) {
			ZoomWebhookHelper.userLogIn(email);
		} else if (event == USER_SIGNED_OUT) {
			ZoomWebhookHelper.userLogOut(email, lastChanged);
		} else if (event == CONTACT_CENTER_USER_LOGIN) {
			ZoomWebhookHelper.contactCenterUserLogin(ccEmail, lastChanged);
		} else if (event == CONTACT_CENTER_USER_LOGOUT) {
			ZoomWebhookHelper.contactCenterUserLogout(ccEmail, lastChanged);
		} else if (event == CONTACT_CENTER_USER_STATUS_CHANGED) {
			ZoomWebhookHelper.contactCenterUserStatusChanged(ccEmail, ccStatus, ccSubStatus, ccPrevStatus, ccPrevSubStatus);
		} else {
			System.debug('Event not found');
		}
	}


}

// {
//     event=user.presence_status_updated,
//     event_ts=1691535992008,
//     payload=
//         {
//         account_id=kJdQOXj6TXeWcSfh_ysPVQ,
//         object=
//             {
//                 date_time=2023-08-08T23:06:32Z,
//                 email=dpatel@myubiquity.com,
//                 id=uzybhvofrtedy8bjbf-eyq,
//                 presence_status=Offline
//             }
//         }
// }

// {
//   "event": "contact_center.user_status_changed",
//   "event_ts": 1627906944384,
//   "payload": {
//     "account_id": "D8cJuqWVQ623CI4Q8yQK0Q",
//     "object": {
//       "user_id": "ukAAkZKfROKMSw1bj_RDFQ",
//       "display_name": "Jill Chill",
//       "user_email": "jchill@example.com",
//       "previous_status_id": "2",
//       "previous_status_name": "Not Ready",
//       "previous_sub_status_id": "20",
//       "previous_sub_status_name": "Break",
//       "current_status_id": "2",
//       "current_status_name": "Not Ready",
//       "current_sub_status_id": "21",
//       "current_sub_status_name": "Meal",
//       "date_time": "2022-02-15T09:27:15Z"
//     }
//   }
// }

// {
//   "event": "contact_center.user_login",
//   "event_ts": 1627906944384,
//   "payload": {
//     "account_id": "D8cJuqWVQ623CI4Q8yQK0Q",
//     "object": {
//       "user_id": "ukAAkZKfROKMSw1bj_RDFQ",
//       "display_name": "Jill Chill",
//       "user_email": "jchill@example.com",
//       "date_time": "2022-02-15T09:27:15Z"
//     }
//   }
// }