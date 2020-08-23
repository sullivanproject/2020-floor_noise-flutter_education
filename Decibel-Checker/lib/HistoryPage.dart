import 'package:flutter/material.dart';
import 'package:flutterapp/SqliteUtil.dart';
import 'SoundData.dart';

/// 소음 측정 내역을 보여주는 화면
/// 첫 페이지에서 우측 상단 버튼을 누르면 볼 수 있는 화면입니다.
class HistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  List<SoundData> history = [];

  @override
  void initState() {
    super.initState();
    // addTestData();
    getAll();
  }

  @override
  Widget build(BuildContext context) {
    getAll();
    return Scaffold(
      appBar: AppBar(title: Text("층간소음 녹음내역")),
      body: Column(
        children: <Widget>[
          generateRow(context, -1),
          Expanded(
              child: ListView.builder(
                itemCount: history.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (_, index) => generateRow(context, index),
              ),
          )
        ],
      ),
    );
  }

  /// 한 줄에 보여줄 데이터를 만든다. */
  Widget generateRow(BuildContext context, int index) {
    if (index == -1)
      return Row(children: <Widget>[
        generateBorderText(context, 0.5, '시간 '),
        generateBorderText(context, 0.25, '평균 데시벨'),
        generateBorderText(context, 0.25, '피크 데시벨')
      ]);
    else
      return Row(children: <Widget>[
        generateBorderText(context, 0.5, history[index].date),
        generateBorderText(context, 0.25, "${history[index].averageDecibel}"),
        generateBorderText(context, 0.25, "${history[index].maxDecibel}")
      ]);
  }

  /// 스타일링된 텍스트뷰를 반환한다. */
  Widget generateBorderText(BuildContext context, double ratio, String text) {
    return Container(
      width: MediaQuery.of(context).size.width * ratio,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Text(text, textAlign: TextAlign.center),
    );
  }

  /// DB로부터 데이터를 받아옵니다.
  void getAll() {
    SqliteUtil.getSoundData().then((value) {
      setState(() {
        history = value;
      });
    });
  }

  /// DB에 더미 데이터를 추가합니다.
  void addTestData(){
    SqliteUtil.onAdd(SoundData(date: parseDate(new DateTime.now()), averageDecibel: 2, maxDecibel: 3));
  }
}
