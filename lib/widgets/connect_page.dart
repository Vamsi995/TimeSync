import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_app/models/CloudUser.dart';
import 'package:flutter_app/models/UserDetails.dart';
import 'package:flutter_app/services/databaseservice.dart';
import 'package:flutter_app/services/notifications.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../globalvars.dart';
import '../models/CloudUser.dart';

class Connect extends StatefulWidget {
  @override
  _ConnectState createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  List<TimeRequest> trans;

  List<int> nums = [1, 2, 3, 4, 5, 6];

  CloudUser user, friend;

  int _time;
  var _timeController = TextEditingController(text: "");
  var _reqTimeController = TextEditingController(text: "");
  bool isSet = false;
  String _remark;
  List<int> hours = new List<int>.generate(5, (i) => i);
  var x1 = ["hrs"];
  var x2 = ["mins"];
  List<int> minutes = new List<int>.generate(60, (i) => i);

  ScrollController _controller = new ScrollController();

  showPickerArray(BuildContext context, bool isReq) {
    Picker(
        adapter: PickerDataAdapter<String>(
          pickerdata: [hours, x1, minutes, x2],
          isArray: true,
        ),
        hideHeader: true,
        selecteds: [1, 0, 29, 0],
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
            if (isReq) {
              _timeController.text = _time.toString();
            } else {
              _reqTimeController.text = _time.toString();
            }
          });
        }).showDialog(context);
  }

  // user defined function
  void _showDialog(CloudUser userDetails) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Request"),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLength: 5,
                controller: _timeController,
                readOnly: true,
                style: TextStyle(fontSize: 25),
                decoration: InputDecoration(icon: Icon(Icons.access_time), helperText: "Time in mins"),
                onChanged: (text) {
                  _time = int.parse(text);
                },
                onTap: () async {
                  showPickerArray(context, true);
                },
              ),
              TextField(
                maxLength: 20,
                style: TextStyle(fontSize: 25),
                decoration: InputDecoration(icon: Icon(Icons.rate_review), helperText: "Enter the Remarks"),
                onChanged: (text) {
                  _remark = text;
                },
              ),
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Get.back();
              },
            ),
            FlatButton(
              child: Text("Request"),
              onPressed: () async {
                await DataBaseService()
                    .writeRequest(TimeRequest(reason: _remark, reqAmount: _time, reqDate: DateTime.now()));
                http.Response res = await NotificationService().sendTimeRequest(
                    "Your friend needs ${(_time ~/ 60)} hrs ${(_time % 60)} mins of additional time\nReason: $_remark",
                    "Time Request");
                Get.back();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _reqTimeController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = DataBaseService().mapFireBasetoCloud(Provider.of<DocumentSnapshot>(context));
    friend = Provider.of<CloudUser>(context);

    Controller c = Get.put(Controller());

    c.vault = user?.vault ?? 0;
    c.friendVault = friend?.vault ?? 0;
    c.requestedAmount = user?.transaction?.reqAmount ?? 0;
    c.acceptedAmount = user?.transaction?.accAmount ?? 0;
    _reqTimeController.text = c.requestedAmount.toString();
    trans = user?.allTransactions ?? [];
    String _getRequestTime(int value) {
      if (value == null) return "";
      int hrs = value ~/ 60;
      int mins = value % 60;

      return "$hrs hrs and $mins mins";
    }

    return Scaffold(
      floatingActionButton: user.isAddict
          ? FloatingActionButton.extended(
              onPressed: () {
                _showDialog(user);
              },
              label: Text("Request"),
            )
          : null,
      backgroundColor: Color(0xFFD7F5FD),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              child: friend == null
                  ? Container()
                  : Column(
                      children: [
                        SizedBox(height: 20),
                        CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 50,
                            child: ClipOval(
                              child: Image.network(
                                '${friend.photoURL}',
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
            Stack(overflow: Overflow.visible, alignment: Alignment.topCenter, children: [
              Container(
                color: Colors.white,
                height: 300,
                child: Container(
                  margin: EdgeInsets.fromLTRB(5, 50, 5, 20),
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: _controller,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(8),
                    itemCount: trans.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text("${trans[index].accAmount}"),
                        ),
                        trailing: CircleAvatar(
                          child: trans[index].accAmount > 0 ? Icon(Icons.check) : Icon(Icons.clear),
                          backgroundColor: trans[index].accAmount > 0 ? Colors.green : Colors.red,
                        ),
                        title: Text("${trans[index].reason}"),
                      );
                    },
                    // separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),
                ),
              ),
              Positioned(
                top: -60,
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
                      TSShow(
                        text: "Vault",
                        value: c.vault.toString(),
                      ),
                      TSShow(
                        text: "Friend Vault",
                        value: c.friendVault.toString(),
                      )
                    ],
                  ),
                ),
              ),
            ]),
            Container(
              margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
              padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [const Color(0xFF21BEFE), const Color(0xFFD7F5FD)], // whitish to gray
                    // tileMode: TileMode.repeated, // repeats the gradient over the canvas
                  )),
              child: !user.isNull && !user.isAddict && !user.requestCompleted
                  ? Column(
                children: [
                  Text("Your friend needs ${_getRequestTime(c.requestedAmount)} of extra time.",
                      style: TextStyle(fontSize: 15)),
                  SizedBox(height: 10),
                  Text("How much would you like to give ?", style: TextStyle(fontSize: 15)),
                  SizedBox(height: 15),
                  Container(
                      width: 300,
                      child: TextField(
                        controller: _reqTimeController,
                        textAlign: TextAlign.center,
                        readOnly: true,
                        style: TextStyle(fontSize: 25),
                        onTap: () {
                          showPickerArray(context, false);
                        },
                        decoration: InputDecoration(
                          icon: Icon(Icons.access_time),
                        ),
                      )),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () async {
                            DataBaseService dbs = DataBaseService();
                            CloudUser friend = await dbs.getFriendDetails();
                            NotificationService nfs = NotificationService();
                            TimeRequest t = await dbs.getRequestDetails();
                            t.accAmount = int.parse(_reqTimeController.text);
                            await dbs.updateRequest(int.parse(_reqTimeController.text));
                            Vault.borrow(t);
                            await dbs.completeRequest();
                            await nfs.sendRequestAccept();
                          },
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () async {
                            DataBaseService dbs = DataBaseService();
                            CloudUser friend = await dbs.getFriendDetails();
                            NotificationService nfs = NotificationService();
                            TimeRequest t = await dbs.getRequestDetails();
                            t.accAmount = 0;
                            await dbs.updateRequest(int.parse(_reqTimeController.text));
                            Vault.borrow(t);
                            await dbs.completeRequest();
                            await nfs.sendRequestRejected();
                          },
                        ),
                      )
                    ],
                  )
                ],
              )
                  : null,
            ),
          ],
        ),
      ),
    );

    // return Scaffold(
    //     backgroundColor: Color(0xFFD7F5FD),
    //     body: Column(
    //   children: [
    //     Expanded(
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //         children: [
    //           Expanded(
    //             child: TSCard(
    //               text: "${c.vault}",
    //               color: Colors.greenAccent,
    //             ),
    //           ),
    //           Expanded(
    //             child: TSCard(
    //               text: "${c.friendVault}",
    //               color: Colors.greenAccent,
    //             ),
    //           )
    //         ],
    //       ),
    //       flex: 1,
    //     ),
    //     Expanded(
    //       child: Container(
    //         decoration: BoxDecoration(
    //           color: Colors.orange,
    //           borderRadius: BorderRadius.circular(10.0),
    //         ),
    //         child: ListView.separated(
    //           padding: const EdgeInsets.all(8),
    //           itemCount: trans.length,
    //           itemBuilder: (BuildContext context, int index) {
    //             return Container(
    //               height: 70,
    //               color: Colors.black,
    //               child: Text('${trans[index]}'),
    //             );
    //           },
    //           separatorBuilder: (BuildContext context, int index) => const Divider(),
    //         ),
    //       ),
    //       flex: 4,
    //     ),
    //     user != null && user.isAddict
    //         ? ButtonCard(
    //             text: "Request",
    //             color: Colors.amber,
    //             onPress: user == null
    //                 ? null
    //                 : () {
    //                     _showDialog(user);
    //                   },
    //           )
    //         : user != null && user.requestCompleted
    //             ? Container()
    //             : Container(
    //                 child: Column(
    //                   children: [
    //                     Text("Your friend needs ${_getRequestTime(c.requestedAmount)} of extra time.",
    //                         style: TextStyle(fontSize: 15)),
    //                     SizedBox(height: 10),
    //                     Text("How much would you like to give ?", style: TextStyle(fontSize: 15)),
    //                     SizedBox(height: 15),
    //                     Container(
    //                         width: 300,
    //                         child: TextField(
    //                           controller: _reqTimeController,
    //                           textAlign: TextAlign.center,
    //                           readOnly: true,
    //                           style: TextStyle(fontSize: 25),
    //                           onTap: () {
    //                             showPickerArray(context, false);
    //                           },
    //                           decoration: InputDecoration(
    //                             icon: Icon(Icons.access_time),
    //                           ),
    //                         )),
    //                     SizedBox(height: 15),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                       children: [
    //                         CircleAvatar(
    //                           radius: 20,
    //                           backgroundColor: Colors.green,
    //                           child: IconButton(
    //                             icon: Icon(Icons.check),
    //                             onPressed: () async {
    //                               DataBaseService dbs = DataBaseService();
    //                               CloudUser friend = await dbs.getFriendDetails();
    //                               NotificationService nfs = NotificationService();
    //                               TimeRequest t = await dbs.getRequestDetails();
    //                               t.accAmount = int.parse(_reqTimeController.text);
    //                               await dbs.updateRequest(int.parse(_reqTimeController.text));
    //                               Vault.borrow(t);
    //                               await dbs.completeRequest();
    //                               await nfs.sendRequestAccept();
    //                             },
    //                           ),
    //                         ),
    //                         CircleAvatar(
    //                           radius: 20,
    //                           backgroundColor: Colors.red,
    //                           child: IconButton(
    //                             icon: Icon(Icons.close),
    //                             onPressed: () async {
    //                               DataBaseService dbs = DataBaseService();
    //                               CloudUser friend = await dbs.getFriendDetails();
    //                               NotificationService nfs = NotificationService();
    //                               TimeRequest t = await dbs.getRequestDetails();
    //                               t.accAmount = 0;
    //                               await dbs.updateRequest(int.parse(_reqTimeController.text));
    //                               Vault.borrow(t);
    //                               await dbs.completeRequest();
    //                               await nfs.sendRequestRejected();
    //                             },
    //                           ),
    //                         )
    //                       ],
    //                     )
    //                   ],
    //                 ),
    //                 margin: EdgeInsets.all(10.0),
    //                 padding: EdgeInsets.all(25.0),
    //                 decoration: BoxDecoration(
    //                   color: Colors.lightBlue,
    //                   borderRadius: BorderRadius.circular(10.0),
    //                 ),
    //               )
    //   ],
    // ));
  }
}

class TSShow extends StatelessWidget {
  final String text;
  final String value;

  TSShow({@required this.text, @required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          this.text,
          style: TextStyle(color: Color(0xFFB4C1CA)),
        ),
        Text(
          this.value,
          style: TextStyle(color: Color(0xFF70D4FF), fontSize: 25),
        ),
      ],
    );
  }
}
