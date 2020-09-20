import 'dart:convert';

import 'package:flutter_app/globalvars.dart';
import 'package:flutter_app/models/LocalUser.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  String uid;
  String fuid;

  NotificationService() {
    this.uid = LocalUser.uid;
    this.fuid = LocalUser.fuid;
  }

  String sendUrl = "https://onesignal.com/api/v1/notifications";
  String apiKey = OS_API_KEY;
  String appID = OS_APP_ID;

  Future<http.Response> sendNotification(String body, String heading, String message) {
    Map<String, String> headers = {"Content-Type": "application/json; charset=utf-8", "Authorization": "Basic $apiKey"};

    return http.post(sendUrl, headers: headers, body: message);
  }

  Future<http.Response> sendTimeExceeded() async {
    String userBody =
        "You have exceeded today's limit. Take loan from your savings or borrow time from your friend if needed";
    String friendBody = "Your friend has exceed the time limit. Consider talking about this.";
    String userHeading = "Time limit exceeded";
    String friendHeading = "Friend exceeded time limit";
    dynamic message = jsonEncode({
      "app_id": appID,
      "headings": {"en": userHeading},
      "contents": {"en": userBody},
      "include_external_user_ids": [uid],
    });
    await sendNotification(userBody, userHeading, message);
    message = jsonEncode({
      "app_id": appID,
      "headings": {"en": userHeading},
      "contents": {"en": userBody},
      "include_external_user_ids": [fuid],
    });
    return sendNotification(friendBody, friendHeading, message);
  }

  Future<http.Response> sendRequestAccept() {
    String body = "Your friend has accepted your request";
    String heading = "Time request accepted";
    dynamic message = jsonEncode({
      "app_id": appID,
      "headings": {"en": heading},
      "contents": {"en": body},
      "include_external_user_ids": [fuid],
    });
    return sendNotification(body, heading, message);
  }

  Future<http.Response> sendRequestRejected() {
    String body = "Your friend has rejected your request";
    String heading = "Time request rejected";
    dynamic message = jsonEncode({
      "app_id": appID,
      "headings": {"en": heading},
      "contents": {"en": body},
      "include_external_user_ids": [fuid],
    });
    return sendNotification(body, heading, message);
  }

  Future<http.Response> sendTimeRequest(String body, String heading) {
    dynamic message = jsonEncode({
      "app_id": appID,
      "headings": {"en": heading},
      "contents": {"en": body},
      "include_external_user_ids": [fuid]
    });
    return sendNotification(body, heading, message);
  }
}
