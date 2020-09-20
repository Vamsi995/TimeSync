import 'package:flutter/material.dart';
import 'package:flutter_app/models/AuthUser.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    _isLoggedIn() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
    }

    final AuthUser authUser = Provider.of<AuthUser>(context);
  }
}

// initialRoute: seen ? '/dash' : '/intro',
// routes: {'/intro': (context) => Intro(), '/dash': (context) => Dash()
