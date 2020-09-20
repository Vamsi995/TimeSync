import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../globalvars.dart';

class ThemePicker extends StatefulWidget {
  ThemePicker({Key ckey}) : super(key: ckey);

  @override
  _ThemePickerState createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker> {
  ThemeMode _themeMode;

  @override
  Widget build(BuildContext context) {
    _themeMode = ThemeController.to.themeMode;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'ThemeMode',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.left,
          ),
          RadioListTile(
            title: Text('dark'),
            value: ThemeMode.dark,
            groupValue: _themeMode,
            onChanged: (value) {
              setState(() {
                _themeMode = value;
                ThemeController.to.setThemeMode(_themeMode);
                Get.back();
              });
            },
          ),
          RadioListTile(
            title: Text('light'),
            value: ThemeMode.light,
            groupValue: _themeMode,
            onChanged: (value) {
              setState(() {
                _themeMode = value;
                ThemeController.to.setThemeMode(_themeMode);
                Get.back();
              });
            },
          ),
        ],
      ),
    );
  }
}
