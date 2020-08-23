import 'package:flutter/material.dart';
import 'package:flutterapp/HomePage.dart';
import 'package:flutterapp/HistoryPage.dart';

/// main 함수
/// Flutter 앱의 첫 시작은 여기부터입니다.
void main() {
  runApp(MyApp());
}

/// 처음에 실행시켜줄 화면을 보여줍니다.
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  var title = '설리번 프로젝트';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
//      home: HistoryPage(title: "층간소음 녹음내역"),
    );
  }
}
