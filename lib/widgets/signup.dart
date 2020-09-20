import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/globalvars.dart';
import 'package:flutter_app/services/authservice.dart';
import 'package:get/get.dart';

import '../constants.dart' as Constants;
import 'custom.dart';
import 'dash.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  Controller c = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Sync"),
        actions: [
          IconButton(
            icon: Icon(Icons.format_color_fill),
            onPressed: () async {
              UtilFunctions.settingModalBottomSheet(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: Get.height * 0.3),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: RaisedButton(
                  color: Color(Constants.COLOR_PRIMARY_DARK),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'I help others',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(8, 3, 0, 0),
                        child: Icon(Icons.chevron_right),
                      )
                    ],
                  ),
                  textColor: Colors.white,
                  splashColor: Color(Constants.COLOR_PRIMARY_DARK),
                  onPressed: () {
                    c.showFriendName = false;
                    Get.to(AddictPage());
                  },
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Color(Constants.COLOR_PRIMARY_DARK))),
                ),
              ),
            ),
            SizedBox(height: 50),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: RaisedButton(
                color: Color(Constants.COLOR_PRIMARY_DARK),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I need help',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(8, 3, 0, 0),
                      child: Icon(Icons.chevron_right),
                    )
                  ],
                ),
                textColor: Colors.white,
                splashColor: Color(Constants.COLOR_PRIMARY_DARK),
                onPressed: () {
                  c.showFriendName = true;
                  Get.to(AddictPage());
                },
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Color(Constants.COLOR_PRIMARY_DARK))),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoginAddict extends StatefulWidget {
  @override
  _LoginAddictState createState() => _LoginAddictState();
}

class _LoginAddictState extends State<LoginAddict> {
  TextEditingController _friend = TextEditingController(text: "");
  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Sync"),
        actions: [
          IconButton(
            icon: Icon(Icons.format_color_fill),
            onPressed: () async {
              UtilFunctions.settingModalBottomSheet(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: Get.height * 0.2),
            Center(
              child: Text(
                "Enter your friend's name if you need help\nelse login directly",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: BeautyTextfield(
                prefixIcon: Icon(Icons.account_circle),
                placeholder: "username",
                controller: _friend,
              ),
            ),
            SizedBox(height: 50),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: RaisedButton(
                color: Color(Constants.COLOR_PRIMARY_DARK),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Log in',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 3, 0, 0),
                      child: Icon(Icons.chevron_right),
                    )
                  ],
                ),
                textColor: Colors.white,
                splashColor: Color(Constants.COLOR_PRIMARY_DARK),
                onPressed: () async {
                  await _authService.googleSignIn("", _friend.text == "", _friend.text);
                  Get.off(Dash());
                },
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Color(Constants.COLOR_PRIMARY_DARK))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddictPage extends StatefulWidget {
  @override
  _AddictPageState createState() => _AddictPageState();
}

class _AddictPageState extends State<AddictPage> {
  Controller c = Get.put(Controller());
  TextEditingController _username = TextEditingController(text: "");
  TextEditingController _friend = TextEditingController(text: "");
  AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Sync"),
        actions: [
          IconButton(
            icon: Icon(Icons.format_color_fill),
            onPressed: () async {
              UtilFunctions.settingModalBottomSheet(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: Get.height * 0.3),
            Center(
              child: BeautyTextfield(
                prefixIcon: Icon(Icons.account_circle),
                placeholder: "username",
                controller: _username,
              ),
            ),
            c.showFriendName
                ? Center(
                    child: BeautyTextfield(
                      prefixIcon: Icon(Icons.account_circle),
                      placeholder: "friend's username",
                      controller: _friend,
                    ),
                  )
                : Container(),
            SizedBox(height: 50),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: RaisedButton(
                color: Color(Constants.COLOR_PRIMARY_DARK),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Log in',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(15, 3, 0, 0),
                      child: Icon(Icons.chevron_right),
                    )
                  ],
                ),
                textColor: Colors.white,
                splashColor: Color(Constants.COLOR_PRIMARY_DARK),
                onPressed: () async {
                  if (c.showFriendName) {
                    await _authService.googleSignIn(_username.text, false, _friend.text);
                  } else {
                    await _authService.googleSignIn(_username.text, true);
                  }
                  Get.off(Dash());
                },
                padding: EdgeInsets.only(top: 12, bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Color(Constants.COLOR_PRIMARY_DARK))),
              ),
            ),
            SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}
