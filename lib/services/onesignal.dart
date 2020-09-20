import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/globalvars.dart';
import 'package:flutter_app/models/AuthUser.dart';
import 'package:flutter_app/models/CloudUser.dart';
import 'package:flutter_app/services/databaseservice.dart';
import 'package:flutter_app/services/notifications.dart';
import 'package:flutter_app/widgets/dash.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import 'authservice.dart';

class OneSignalService {
  void initOneSignal(bool mounted) {
    if (!mounted) return;
    registerOneSignal();
    registerNotificationHandlers();
    print("[ -- Registered One Signal -- ]");
  }

  void registerOneSignal() async {
    await OneSignal.shared
        .init(OS_APP_ID, iOSSettings: {OSiOSSettings.autoPrompt: false, OSiOSSettings.inAppLaunchUrl: false});
    await OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setSubscriptionObserver((changes) async {
      if (!changes.from.subscribed && changes.to.subscribed) {
        DataBaseService().addUserExtID();
      }
    });
  }

  void registerNotificationHandlers() {
    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) async {
      AuthUser authDetails = AuthService().getCurrentUser();
      CloudUser user = await DataBaseService().getFriendDetails();
      DataBaseService dbs = DataBaseService();
      NotificationService nfs = NotificationService();
      if (notification.payload.title == "Friend Request") {
      } else if (notification.payload.title == "Time Request") {
      } else if (notification.payload.title == "Time Request accepted") {}
    });
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) async {
      AuthUser authDetails = AuthService().getCurrentUser();
      CloudUser user = await DataBaseService().getFriendDetails();
      DataBaseService dbs = DataBaseService();
      NotificationService nfs = NotificationService();
      if (result.notification.payload.title == "Friend Request") {
        if (result.action.actionId == "accept") {
          print("Accepted");
        } else {
          print("Rejected");
        }
      } else if (result.notification.payload.title == "Time Request") {
        TimeRequest t = await DataBaseService().getRequestDetails();
        Controller c = Get.put(Controller());
        if (result.action.type == OSNotificationActionType.opened) {
          c.dashIndex = 2;
          Get.off(StreamProvider<DocumentSnapshot>.value(
            value: DataBaseService().userDetails,
            child: Dash(),
          ));
        }
      }
    });
  }
}
