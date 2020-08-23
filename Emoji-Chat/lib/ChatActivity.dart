import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatItem.dart';

class ChatActivity extends StatefulWidget {
  String user = "";

  ChatActivity(String user) {
    this.user = user;
  }

  @override
  State<StatefulWidget> createState() => ChatActivityState(user);
}

class ChatActivityState extends State<ChatActivity> {
  String user = "";
  String me = "";
  List<ChatItem> items = List();

  ScrollController _scrollController = new ScrollController();

  ChatActivityState(String user) {
    this.user = user;
  }

  @override
  void initState() {
    super.initState();
    getAll();
    listen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user + "호"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (_, index) => generateRow(_, index),
              itemCount: items.length,
              scrollDirection: Axis.vertical,
            ),
          ),
          EmojiPicker(
            rows: 3,
            columns: 7,
            numRecommended: 10,
            onEmojiSelected: (emoji, category) {
              sendEmoji(emoji);
            },
          )
        ],
      ),
    );
  }

  Widget generateRow(BuildContext context, int index) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      padding: EdgeInsets.all(24),
      child: Align(
        alignment: items[index].to == me
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: Column(
          crossAxisAlignment: items[index].to == me
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              items[index].time,
              style: TextStyle(color: Colors.black12, fontSize: 16),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              child: Text(
                items[index].text,
                style: TextStyle(color: Colors.black, fontSize: 64),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendEmoji(Emoji emoji) {
    ChatItem item = new ChatItem();
    item.to = user;
    item.from = me;
    item.time = getTime();
    item.text = emoji.emoji;

    Firestore.instance.collection("chat").document("apartment").updateData({
      "chat": FieldValue.arrayUnion([item.toMap()])
    }).then((value) {
//      getAll();
    });
  }

  String getTime() {
    DateFormat df = DateFormat("yyyy/MM/dd hh:mm");
    return df.format(DateTime.now());
  }

  void listen(){
    Firestore.instance.collection("chat").document("apartment").snapshots().listen((event) {
      items.clear();

      List<Map> list = List.castFrom(event.data["chat"]).cast<Map>();
      List<ChatItem> list2 = List();
      List<ChatItem> list3 = List();

      for (Map m in list) {
        list2.add(ChatItem.fromMap(m));
      }

      for (ChatItem i in list2) {
        if ((i.to == me && i.from == user) || (i.from == me && i.to == user))
          list3.add(i);
      }
      setState(() {
        items = list3;
      });

      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    });
  }

  void getAll() async {
    items.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    me = prefs.getString("id");
    Firestore.instance
        .collection("chat")
        .document("apartment")
        .get()
        .then((value) {
      //do not code like this
      List<Map> list = List.castFrom(value.data["chat"]).cast<Map>();
      List<ChatItem> list2 = List();
      List<ChatItem> list3 = List();

      for (Map m in list) {
        list2.add(ChatItem.fromMap(m));
      }

      for (ChatItem i in list2) {
        if ((i.to == me && i.from == user) || (i.from == me && i.to == user))
          list3.add(i);
      }
      setState(() {
        items = list3;
      });

      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    });
  }
}
