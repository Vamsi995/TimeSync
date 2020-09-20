import 'package:flutter/material.dart';
import 'package:flutter_app/services/authservice.dart';
import 'package:flutter_app/widgets/signup.dart';
import 'package:get/get.dart';

import '../constants.dart' as Constants;
import '../globalvars.dart';

class AuthScreen extends StatelessWidget {
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Image.asset('assets/images/Logo.png'),
              ),
            ),
            Text(
              'TimeSync',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(Constants.COLOR_PRIMARY), fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: RaisedButton(
                  color: Color(Constants.COLOR_PRIMARY),
                  child: Text(
                    'Log In',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  textColor: Colors.white,
                  splashColor: Color(Constants.COLOR_PRIMARY),
                  onPressed: () async {
                    Get.to(LoginAddict());
                  },
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Color(Constants.COLOR_PRIMARY))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: FlatButton(
                  color: Color(Constants.COLOR_PRIMARY_DARK),
                  textColor: Colors.white,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Get.to(SignUp());
                  },
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0), side: BorderSide(color: Colors.black54)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
