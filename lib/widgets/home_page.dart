import 'dart:async';

import 'package:app_usage/app_usage.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/globalvars.dart';
import 'package:flutter_app/models/CloudUser.dart';
import 'package:flutter_app/models/LocalUser.dart';
import 'package:flutter_app/models/UserDetails.dart';
import 'package:flutter_app/services/databaseservice.dart';
import 'package:flutter_app/services/notifications.dart';
import 'package:flutter_app/widgets/Charts/pie_chart.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'Charts/line_chart.dart';
import 'custom.dart';

class AppTime {
  Duration total;
  int seconds;
  String name;
  double percentage;

  AppTime(Duration total, int seconds, String name) {
    this.total = total;
    this.seconds = seconds;
    this.name = name;
  }
}

double total(List<AppUsageInfo> today) {
  double sum = 0;

  today.forEach((element) {
    sum += element.usage.inMinutes;
  });

  return sum;
}

Future<double> getPrevWeekUsage() async {
  DateTime date = DateTime.now();

  DateTime startDate = date.subtract(new Duration(days: 13));

  List<AppUsageInfo> today = await AppUsage.getAppUsage(startDate, date);

  double avg = total(today) / today.length;
  return avg;
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];
  List<AppUsageInfo> _infos;
  List<AppTime> percentageData;
  List<AppUsageInfo> weekData;
  List<double> lineChartData = new List();
  Controller c = Get.put(Controller());

  CloudUser user;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    c.showLinechart = true;
    getLineChartData().then((value) {
      c.showLinechart = false;
    });
    getUsageStats();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getUsageStats() async {
    try {
      DateTime endDate = new DateTime.now();
      DateTime date = new DateTime(endDate.year, endDate.month, endDate.day);

      DateTime weekDay = DateTime.now();
      DateTime week = weekDay.subtract(new Duration(days: weekDay.weekday));

      List<AppUsageInfo> today = await AppUsage.getAppUsage(date, endDate);

      if (mounted) {
        setState(() {
          _infos = today;
          percentageData = convertStats(today);
        });
      }
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  double total(List<AppUsageInfo> today) {
    double sum = 0;

    today.forEach((element) {
      sum += element.usage.inMinutes;
    });

    return sum;
  }

  Future<void> getLineChartData() async {
    for (int i = 0; i < 8; i++) {
      DateTime weekDay = DateTime.now();
      DateTime week = weekDay.subtract(new Duration(days: i));
      DateTime date = new DateTime(week.year, week.month, week.day);
      DateTime endTime = date.add(new Duration(days: 1));

      List<AppUsageInfo> today = await AppUsage.getAppUsage(date, endTime);

      double ans = total(today);

      if (mounted) {
        setState(() {
          if (lineChartData != null) lineChartData.add(ans);
        });
      }
    }
  }

  List<AppTime> convertStats(List<AppUsageInfo> data) {
    if (data == null) return null;

    List<AppTime> store = [];
    data.forEach((element) {
      // if (element.appName != "flutter_app" && element.appName != "nexuslauncher")
      store.add(AppTime(element.usage, element.usage.inSeconds, element.appName));
    });

    store.sort((a, b) => b.seconds.compareTo(a.seconds));
    store = store.sublist(0, store.length);

    store = getPercentages(store);

    return store;
  }

  List<AppTime> getPercentages(List<AppTime> list) {
    double sum = 0;

    list.forEach((element) {
      sum += element.seconds;
    });

    list.forEach((element) {
      element.percentage = (element.seconds / sum) * 100;
    });

    return list;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      // This is the fetch-event callback.
      print("[BackgroundFetch] Event received $taskId");

      getUsageStats();
      getLineChartData();

      DateTime today = DateTime.now();
      DateTime startToday = DateTime(today.year, today.month, today.day);

      Duration diff = today.difference(startToday);

      int totalTime = await getDailyUsage();

      if (DateTime.now().difference(startToday) < Duration(minutes: 15)) {
        Vault.dailySaving();
        CloudUser user = await DataBaseService().getUserDetails();
        if (!LocalUser.normal && user.isAddict) {
          Vault.timeDecay();
        }
      }

      if (user != null && user.isAddict && user.dailyLimit < totalTime) NotificationService().sendTimeExceeded();

      if (mounted) {
        setState(() {
          _events.insert(0, new DateTime.now());
        });
      }

      print(_infos);
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      if (mounted) {
        setState(() {
          _status = e;
        });
      }
    });

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    if (mounted) {
      setState(() {
        _status = status;
      });
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = DataBaseService().mapFireBasetoCloud(Provider.of<DocumentSnapshot>(context));
    return Scaffold(
      backgroundColor: Color(0xFFD7F5FD),
      body: ListView(
        //View change
        children: [
          Stack(children: <Widget>[
            TSCard(text: '', color: Colors.tealAccent),
            Align(
              alignment: Alignment(-0.75, 0),
              child: percentageData == null ? null : PieChartSample2(inputData: percentageData),
            ),
            Align(alignment: Alignment(0.8, -0.75), child: TSText(text: 'Your Time')),
          ]),
          Stack(
            children: <Widget>[
              TSCard(text: '', color: Colors.tealAccent),
              Align(
                  alignment: Alignment(-0.75, 0),
                  child: !c.showLinechart ? LineChartSample2(inputData: lineChartData) : CircularProgressIndicator()),
              Align(
                  alignment: Alignment(0, -0.5),
                  child: Text(
                    'Your Progress',
                    style: TextStyle(
                      color: Colors.white.withOpacity(1.0),
                      fontSize: 25,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
