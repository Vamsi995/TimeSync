import 'package:app_usage/app_usage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_app/globalvars.dart';
import 'package:flutter_app/models/AuthUser.dart';
import 'package:flutter_app/models/CloudUser.dart';
import 'package:flutter_app/models/UserDetails.dart';
import 'package:flutter_app/services/databaseservice.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'custom.dart';
import 'home_page.dart';

const int FRIEND_VAULT_FACTOR = 10;


class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  CalendarController _calendarController = CalendarController();
  UtilFunctions utilFunctions = UtilFunctions();

  bool flag = true;

  CloudUser user;
  CloudUser friend;

  bool _goal = false;
  int _time;
  int _dur;
  Duration _diff;
  DateTime _dDay;
  double prevAvg = 0.0;
  bool valid = true;
  bool normal = true;
  bool isMode1Selected = false;

  int trophies;

  final Map<DateTime, List> _ot = {
    DateTime(2020, 9, 14): ['4.5'],
    DateTime(2020, 9, 12): ['5.0'],
  };

  Future<void> updateCalendar() async {
    int limit = (await DataBaseService().getUserDetails()).dailyLimit;

    if (limit == 0) {
      return;
    }

    for (int i = 0; i < 14; i++) {
      DateTime weekDay = DateTime.now();
      DateTime week = weekDay.subtract(new Duration(days: i));
      DateTime date = new DateTime(week.year, week.month, week.day);
      DateTime endTime = date.add(new Duration(days: 1));

      List<AppUsageInfo> today = await AppUsage.getAppUsage(date, endTime);

      double usage = total(today);

      if (usage > limit) {
        _ot[date] = [''];
      }
    }
  }

  var _timeController = TextEditingController(text: "");

  List<int> hours = new List<int>.generate(5, (i) => i);
  var x1 = ["hrs"];
  var x2 = ["mins"];
  List<int> minutes = new List<int>.generate(60, (i) => i);

  showPickerArray(BuildContext context) {
    Picker(
        adapter: PickerDataAdapter<String>(
          pickerdata: [hours, x1, minutes, x2],
          isArray: true,
        ),
        hideHeader: true,
        selecteds: [hours.length ~/ 2, 0, minutes.length ~/ 2, 0],
        title: Text("Select request time"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        cancel: FlatButton(
            onPressed: () {
              Get.back();
            },
            child: Text("Close")),
        onConfirm: (Picker picker, List value) {
          List<String> selected = picker.getSelectedValues();
          _time = int.parse(selected[0]) * 60 + int.parse(selected[2]);
          setState(() {
            _timeController.text = utilFunctions.minsToTime(_time);
          });
        }).showDialog(context);
  }

  Widget theGoalSet(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonCard(
                text: "Model 1",
                color: normal ? Colors.green : Colors.deepOrangeAccent,
                onPress: () {
                  setState(() {
                    normal = !normal;
                  });
                },
              ),
              ButtonCard(
                text: "Model 2",
                color: !normal ? Colors.green : Colors.deepOrangeAccent,
                onPress: () {
                  setState(() {
                    normal = !normal;
                  });
                },
              )
            ],
          ),
          TextField(
            style: TextStyle(fontSize: 25),
            controller: _timeController,
            readOnly: true,
            // maxLength: 10,
            // keyboardType: TextInputType.number,
            decoration: InputDecoration(
              icon: Icon(Icons.access_time),
              helperText:
                  "Enter Daily Quota, max = ${prevAvg.floor()} hrs ${(60 * (prevAvg - prevAvg.floor())).ceil()} mins",
            ),
            onTap: () {
              showPickerArray(context);
            },
            onChanged: (text) {
              _time = double.parse(text).round();
              setState(() {
                valid = _time <= prevAvg * 60;
              });
            },
          ),
          TextField(
            maxLength: 5,
            style: TextStyle(fontSize: 25),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(icon: Icon(Icons.view_week), helperText: "Enter the weeks to follow"),
            onChanged: (text) {
              _dur = int.parse(text);
            },
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _goal = true;
                    });
                  },
                ),
              ),
              Visibility(
                visible: valid,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: Icon(Icons.check),
                    color: Colors.black,
                    onPressed: () async {
                      setState(() {
                        _goal = true;
                        DateTime now = DateTime.now();
                        // _dDay = now.add(Duration(days: _dur * 7));
                        _dDay = now.add(Duration(minutes: _dur));
                        _diff = _dDay.difference(now);
                        flag = false;
                      });
                      CloudUser.setDeadline(_dDay);
                      CloudUser.setDailyLimit(_time);

                      // Todo - Set friends vault
                      DataBaseService().updateFriendVault(_dur * 7 * FRIEND_VAULT_FACTOR);
                      if (!normal) {
                        Vault.decayCompute(prevAvg, _dur);
                      }
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget theGoal() {
    return Row(
      children: [
        Expanded(
          child: TSCard(
            text: "Daily Limit: " +
                (_time ?? 0 / 60).toStringAsFixed(2) +
                " hrs" +
                "\n" +
                "Duration: " +
                (_diff == null ? 0 : _diff.inDays).toString() +
                " days, " +
                (_diff == null ? 0 : _diff.inHours - 24 * (_diff == null ? 0 : _diff.inDays)).toString() +
                " hrs",
            color: Colors.lightBlue,
            padding: 30,
          ),
          flex: 10,
        ),
      ],
    );
  }

  prevWeekAvg() async {
    double temp = await getPrevWeekUsage() / 60;
    if (mounted) {
      setState(() {
        int maxHours = temp.floor();
        hours = List.generate(maxHours + 1, (index) => index);
        prevAvg = temp;
      });
    }
  }

  getDuration() {
    if (user == null) return;
    if (user.isAddict) {
      _dDay = user.deadline;

      if (user.dailyLimit > 0) _time = user.dailyLimit;

      if (_dDay != null) {
        DateTime now = DateTime.now();
        _diff = _dDay.difference(now);
        _goal = _diff.inSeconds < 0 ? false : true;
        if (!flag && !_goal) {
          Vault.goalEnd();
          flag = true;
        }
      } else {
        _goal = false;
      }
    } else {
      if (friend == null) {
        _goal = true;
        return;
      }
      setState(() {
        _dDay = friend.deadline ?? 0;
        _time = friend.dailyLimit ?? 0;
        DateTime now = DateTime.now();
        _diff = _dDay.difference(now);
        _goal = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updateCalendar();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Approve'),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthUser authUser = Provider.of<AuthUser>(context);
    user = DataBaseService().mapFireBasetoCloud(Provider.of<DocumentSnapshot>(context));
    friend = Provider.of<CloudUser>(context);
    Controller c = Get.put(Controller());
    getDuration();
    prevWeekAvg();

    trophies = user?.trophies ?? 0;

    c.name = user?.name ?? "";
    c.fname = friend?.name ?? "";

    return Scaffold(
      backgroundColor: Color(0xFFD7F5FD),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            overflow: Overflow.visible,
            children: [
              Container(
                height: 250,
                width: 500,
                child: authUser == null
                    ? Container()
                    : Column(
                        children: [
                          SizedBox(height: 20),
                          CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 50,
                              child: ClipOval(
                                child: Image.network(
                                  '${authUser.photoURL}',
                                ),
                              )),
                          SizedBox(height: 20),
                          Text("${c.name}"),
                        ],
                      ),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight, // 10% of the width, so there are ten blinds.
                  colors: [const Color(0xFF21BEFE), const Color(0xFFD7F5FD)], // whitish to gray
                  // tileMode: TileMode.repeated, // repeats the gradient over the canvas
                )),
              ),
              Positioned(
                  bottom: -50,
                  child: Container(
                    height: 110,
                    width: 370,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [BoxShadow(color: Color(0xFF21BEFE), blurRadius: 7)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Mode - 1",
                              style: TextStyle(
                                  color: isMode1Selected ? Colors.blue : Colors.blue[300],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        )),
                        Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Mode - 2",
                              style: TextStyle(
                                  color: !isMode1Selected ? Colors.blue : Colors.blue[300],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        )),
                        FlatButton(
                          child: Icon(Icons.help_outline, color: Colors.grey),
                          splashColor: Colors.transparent,
                          onPressed: () {
                            _showMyDialog();
                          },
                        )
                      ],
                    ),
                  )),
              Positioned(
                bottom: -100,
                child: Container(
                  child: Text("hi"),
                ),
              )
            ],
          ),
        ],
      ),
    );

    //   Scaffold(
    //   body: SingleChildScrollView(
    //     child: Column(
    //       children: [
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           children: [
    //             TSCard(
    //               text: c.name,
    //               color: Colors.blueGrey,
    //             ),
    //             TSCard(
    //               text: c.fname,
    //               color: Colors.blueGrey,
    //             ),
    //           ],
    //         ),
    //         _goal ? theGoal() : theGoalSet(context),
    //         TSCard(
    //           text: "Trophies = $trophies",
    //           color: Colors.orange,
    //           padding: 30,
    //         ),
    //         user==null?Text(""):user.isAddict?TSCalender(
    //           calendarController: _calendarController,
    //           ot: _ot,
    //         ):Text("")
    //       ],
    //     ),
    //   ),
    // );
  }
}

class TSCalender extends StatelessWidget {
  const TSCalender({
    Key key,
    @required CalendarController calendarController,
    @required Map<DateTime, List> ot,
  })  : _calendarController = calendarController,
        _ot = ot,
        super(key: key);

  final CalendarController _calendarController;
  final Map<DateTime, List> _ot;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarController: _calendarController,
      initialCalendarFormat: CalendarFormat.twoWeeks,
      availableCalendarFormats: {CalendarFormat.twoWeeks: 'two-weeks'},
      builders: CalendarBuilders(
        holidayDayBuilder: (context, date, events) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.redAccent,
          ),
          child: Text(date.day.toString()),
        ),
      ),
      holidays: _ot,
      weekendDays: [],
    );
  }
}
