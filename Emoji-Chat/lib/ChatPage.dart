import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatActivity.dart';

class ChatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatPageState();
}

class ChatPageState extends State<StatefulWidget> {
  List<String> nb = [];

  @override
  void initState() {
    super.initState();
    getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: nb.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (_, index) => GestureDetector(
                child: generateRow(context, index),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ChatActivity(nb[index])),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget generateRow(BuildContext context, int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.black))),
      child: Text(
        nb[index] + "호",
        style: TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
  }

  void getAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Firestore.instance
        .collection("apartment")
        .document(prefs.getString("id"))
        .get()
        .then((value) {
      setState(() {
        nb = List.castFrom(value.data["nb"]).cast<String>();
      });
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
}
