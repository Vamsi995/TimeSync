import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/AuthUser.dart';
import 'package:flutter_app/models/LocalUser.dart';
import 'package:flutter_app/services/authservice.dart';
import 'package:flutter_app/services/databaseservice.dart';
import 'package:flutter_app/services/onesignal.dart';
import 'package:flutter_app/widgets/dash.dart';
import 'package:flutter_app/widgets/onboarding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'globalvars.dart';
import 'models/CloudUser.dart';

bool seen;

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  BackgroundFetch.finish(taskId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStorage.init();
  if (LocalUser.seen == null) {
    LocalUser.setSeen(false);
  }
  Get.lazyPut<ThemeController>(() => ThemeController());
  seen = LocalUser.seen;
  await DotEnv().load('.env');
  await ThemeController.to.getThemeModeFromPreferences();
  runApp(Main());
  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    super.initState();
    OneSignalService().initOneSignal(mounted);
  }

  @override
  Widget build(BuildContext context) {
    ThemeController.to.getThemeModeFromPreferences();

    return StreamProvider<AuthUser>.value(
      value: AuthService().authUser,
      child: StreamProvider<CloudUser>.value(
        value: DataBaseService().friendDetails,
        child: StreamProvider<DocumentSnapshot>.value(
          value: DataBaseService().userDetails,
          child: GetMaterialApp(
            theme: ThemeData(brightness: Brightness.light, backgroundColor: Colors.red)
                .copyWith(primaryColor: Colors.blue),
            darkTheme: ThemeData(brightness: Brightness.light, backgroundColor: Colors.red)
                .copyWith(primaryColor: Colors.purple),
            themeMode: ThemeController.to.themeMode,
            initialRoute: seen ? '/dash' : '/intro',
            routes: {'/intro': (context) => OnBoardingPage(), '/dash': (context) => Dash()},
          ),
        ),
      ),
    );
  }
}
