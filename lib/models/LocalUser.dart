import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/globalvars.dart';
import 'package:flutter_app/models/CloudUser.dart';
import 'package:flutter_app/services/databaseservice.dart';

import '../globalvars.dart';

class LocalUser {
  static String get uid {
    return LocalStorage.localStorage.getString("uid");
  }

  static String get fuid {
    return LocalStorage.localStorage.getString("fuid");
  }

  static bool get seen {
    return LocalStorage.localStorage.getBool("seen");
  }

  static Future<void> setSeen(bool isNotNew) async {
    await LocalStorage.localStorage.setBool("seen", isNotNew);
  }

  static Future<void> setUid(String uid) async {
    await LocalStorage.localStorage.setString("uid", uid);
  }

  static Future<void> setFuid(String fuid) async {
    await LocalStorage.localStorage.setString("fuid", fuid);
  }

  static Future<void> setFriendDetails() async {
    CloudUser user = await DataBaseService().getFriendDetails();
    if (user == null || fuid != null) return;
    setFuid(user.uid);
  }

  static double get timeDecay {
    return LocalStorage.localStorage.getDouble("timeDecay");
  }

  static Future<void> setTimeDecay(double value) async {
    await LocalStorage.localStorage.setDouble("timeDecay", value);
  }

  static bool get normal {
    return LocalStorage.localStorage.getBool("normal");
  }

  static Future<void> setNormal(bool value) async {
    await LocalStorage.localStorage.setBool("normal", value);
  }

}
