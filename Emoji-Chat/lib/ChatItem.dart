import 'package:intl/intl.dart';

class ChatItem {
  String from, to, text, time;

  ChatItem({this.from, this.to, this.text, this.time});

  Map<String, dynamic> toMap() =>
      {'from': from, 'to': to, 'text': text, 'time': time};

  static ChatItem fromMap(Map map) => ChatItem(
      from: map["from"], to: map["to"], text: map["text"], time: map["time"]);
}

/// 지정된 DateTime 값을 정제된 문자열로 파싱합니다.
String parseDate(DateTime dateTime) {
  DateFormat df = DateFormat("yyyy.MM.dd hh:mm");
  return df.format(dateTime);
}
