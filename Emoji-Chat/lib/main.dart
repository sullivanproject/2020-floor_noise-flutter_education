import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SetupPage.dart';

/// main 함수
/// Flutter 앱의 첫 시작은 여기부터입니다.
void main() {
  runApp(MyApp());
}

/// 처음에 실행시켜줄 화면을 보여줍니다.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "층간소음 앱",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: new Splash());
  }
}

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashState();
}

class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  Future checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = false;
    if (prefs.getString("id") != null) {
      if (prefs.getString("id").isNotEmpty) isLogin = true;
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => isLogin ? HomePage() : SetupPage()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        color: Colors.white,
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) => checkLogin();
}
