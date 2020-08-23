import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/HomePage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';

class SetupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SetupPageState();
}

class SetupPageState extends State<StatefulWidget> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Future scan() async {
    String code = await scanner.scan();
    setState(() => setup(code));
  }

  void setup(String code) {
    code = code.replaceAll("sullivan: ", "");

    Firestore.instance
        .collection('apartment')
        .document(code)
        .get()
        .then((DocumentSnapshot ds) {
      if (ds == null || ds["login"]) {
        toast("이미 등록된 가구입니다.");
      } else {
        Firestore.instance
            .collection("apartment")
            .document(code)
            .updateData({"login": true}).then((value) => login(code));
      }
    });
  }

  void login(String code) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("id", code);

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => HomePage(),
    ));
  }

  void toast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 32),
              child:
              Lottie.asset("assets/raw/qr.json", width: 150, height: 150),
            ),
            Text(
              "환영합니다!",
              style: TextStyle(fontSize: 30),
            ),
            Text(
              "본인의 QR코드를 스캔해 로그인을 진행해 주세요.",
              style: TextStyle(fontSize: 16),
            ),
            Container(
                margin: EdgeInsets.only(top: 16),
                child: RaisedButton(
                  child: Text(
                    "QR 스캔하기",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blue,
                  onPressed: () => scan(),
                ))
          ],
        ),
      ),
    );
  }
}
