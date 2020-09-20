import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/initial_page.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Get.off(AuthScreen());
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/images/$assetName', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0, fontFamily: "Exo2");
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontFamily: "Exo2", fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 10.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Time Sync",
          body: "",
          image: _buildImage('Logo.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "What is TimeSync?",
          body:
              "TimeSync is a well-being app that helps you regulate your screen time. We take the saying \"Time is precious \" to the next level. This app uses app- blocking and the concept of accountability partner and habit contract to help you achieve your goal.",
          image: _buildImage('Logo.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Help Seeker",
          body:
              "If you need help with regulating your screen time then you are the help seeker when you exceed your daily time limit your apps get blocked or you can use the time you can save on previous days or ask your helper.",
          image: _buildImage('Logo.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Helper",
          body:
              "Helper is the partner whom you choose at registration. The Helper has the freedom to accept, deny, or change the requested amount of time-based on your need and thus allowing you to use your apps again. The help seeker hasto repay the amount requested by cutting down screentime on some other day. ",
          image: _buildImage('Logo.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "He who has a why to live can bear almost any how",
          body: "           - Nietzsche",
          image: _buildImage('Logo.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text("This is the screen after Introduction")),
    );
  }
}
