import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

String OS_API_KEY = DotEnv().env["OS_API_KEY"];
String OS_APP_ID = DotEnv().env["OS_APP_ID"];

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  SharedPreferences prefs;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    Get.changeThemeMode(themeMode);
    _themeMode = themeMode;
    update();
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeMode.toString().split('.')[1]);
  }

  getThemeModeFromPreferences() async {
    ThemeMode themeMode;
    prefs = await SharedPreferences.getInstance();
    String themeText = prefs.getString('theme') ?? 'system';
    try {
      themeMode = ThemeMode.values.firstWhere((e) => describeEnum(e) == themeText);
    } catch (e) {
      themeMode = ThemeMode.system;
    }
    setThemeMode(themeMode);
  }
}

class Controller extends GetxController {
  int dashIndex = 1;
  int vault = 0;
  int friendVault = 0;
  int requestedAmount = 0;
  int acceptedAmount = 0;
  bool showFriendName = false;
  String name = "";
  String fname = "";
  bool showLinechart = false;
}

class UtilFunctions {
  String minsToTime(int mins) {
    return "${mins ~/ 60} hrs ${mins % 60} mins";
  }

  static void settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return ThemePicker();
        });
  }

  static void printf(Object object) {
    print("========================================================");
    print(object);
    print("========================================================");
  }
}

class LocalStorage {
  static SharedPreferences localStorage;

  static Future init() async {
    localStorage = await SharedPreferences.getInstance();
  }
}
