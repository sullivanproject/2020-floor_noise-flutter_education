import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/ChatPage.dart';
import 'package:flutterapp/HistoryPage.dart';
import 'package:flutterapp/SoundPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';

/// 첫 페이지
/// 소음을 측정하는 화면입니다.
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int currentIndex = 0;
  final List<Widget> tabs = [SoundPage(), ChatPage()];
  String title;

  void onNavTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Firestore.instance
        .collection("apartment")
        .document(prefs.getString("id"))
        .updateData({"login": false});

    await prefs.setString("id", null);
    SystemNavigator.pop();
  }

  void getCurrentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      title = prefs.getString("id") + "호";
    });
  }

  Future scan() async {
    String code = await scanner.scan();
    code = code.replaceAll("sullivan: ", "");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String me = prefs.getString("id");
    Firestore.instance.collection("apartment").document(me).updateData({
      "nb": FieldValue.arrayUnion([code])
    }).then((value) {
      Firestore.instance.collection("apartment").document(code).updateData({
        "nb": FieldValue.arrayUnion([me])
      }).then((value) => toast("성공적으로 추가했습니다!"));
    });
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
  void initState() {
    super.initState();
    title = "";
    getCurrentId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(title), backgroundColor: Colors.blue, actions: [
        IconButton(
          icon: new Icon(Icons.exit_to_app),
          highlightColor: Colors.white,
          onPressed: () => logout(),
        ),
        IconButton(
          icon: new Icon(Icons.history),
          highlightColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HistoryPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: new Icon(Icons.center_focus_weak),
          highlightColor: Colors.white,
          onPressed: () => scan(),
        ),
      ]),
      body: tabs[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onNavTap,
        currentIndex: currentIndex,
        items: [
          new BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), title: Text("소음 측정")),
          new BottomNavigationBarItem(
              icon: Icon(Icons.tag_faces), title: Text("이모티콘"))
        ],
      ),
    );
  }
}
