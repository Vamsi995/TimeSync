import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/globalvars.dart';
import 'package:flutter_app/models/LocalUser.dart';
import 'package:flutter_app/services/authservice.dart';
import 'package:flutter_app/widgets/initial_page.dart';
import 'package:get/get.dart';

import 'connect_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class Dash extends StatefulWidget {
  @override
  _DashState createState() => _DashState();
}

class _DashState extends State<Dash> {
  Controller c = Get.put(Controller());

  PageController _pageController;

  @override
  void initState() {
    super.initState();
    LocalUser.setFriendDetails();
    _pageController = PageController(initialPage: c.dashIndex, keepPage: true);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [Profile(), Home(), Connect()];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Time Sync'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.not_interested),
              onPressed: () async {
                await LocalStorage.localStorage.clear();
                Get.off(AuthScreen());
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await AuthService().deleteUser();
                Get.off(AuthScreen());
              },
            ),
            IconButton(
              icon: Icon(Icons.format_color_fill),
              onPressed: () async {
                UtilFunctions.settingModalBottomSheet(context);
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: c.dashIndex,
          showElevation: true, // use this to remove appBar's elevation
          onItemSelected: (index) => setState(() {
            c.dashIndex = index;
            _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
          }),
          items: [
            BottomNavyBarItem(
              icon: Icon(Icons.person),
              title: Text("Profile"),
              activeColor: Colors.red,
            ),
            BottomNavyBarItem(icon: Icon(Icons.home), title: Text("Home"), activeColor: Colors.blue),
            BottomNavyBarItem(icon: Icon(Icons.supervised_user_circle), title: Text("Users"), activeColor: Colors.pink),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (newPage) {
            setState(() {
              c.dashIndex = newPage;
            });
          },
          children: _children,
        ),
      ),
    );
  }
}
