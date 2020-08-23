import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutterapp/HistoryPage.dart';
import 'package:flutterapp/SoundPager.dart';
import 'package:noise_meter/noise_meter.dart';

import 'SoundData.dart';
import 'SqliteUtil.dart';

/// 첫 페이지
/// 소음을 측정하는 화면입니다.
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<StatefulWidget> {
  NoiseMeter noiseMeter = new NoiseMeter();
  StreamSubscription<NoiseReading> subscription;
  SoundPager clip = new SoundPager();

  final int limitDecibel = 100;
  int currentDecibel = 0;

  @override
  void initState() {
    super.initState();
    this.subscription = noiseMeter.noiseStream.listen(this.onData);
  }

  @override
  void onData(NoiseReading sound) {
    setState(() {
      var decibel = sound.maxDecibel.toInt();
      this.currentDecibel = decibel;
      this.clip.addSound(decibel);
    });
  }

  bool isSafeDecibel() {
    return currentDecibel < limitDecibel;
  }

  // 0.0 ~ 1.0 사이의 숫자가 반환됩니다.
  double currentDecibelPercent() {
    if (currentDecibel > limitDecibel) {
      return 1;
    } else {
      return currentDecibel / limitDecibel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("소음 측정기"), actions: [
        IconButton(
          icon: new Icon(Icons.search),
          highlightColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HistoryPage(),
              ),
            );
          },
        ),
      ]),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: FAProgressBar(
              direction: Axis.vertical,
              currentValue: currentDecibel,
              maxValue: limitDecibel,
              borderRadius: 0,
              verticalDirection: VerticalDirection.up,
              progressColor: isSafeDecibel() ? Colors.blue : Colors.red,
            ),
          ),
          Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: currentDecibelPercent(),
                  strokeWidth: 12,
                  valueColor: AlwaysStoppedAnimation(
                      isSafeDecibel() ? Colors.blue : Colors.red),
                ),
              ),
              Text("$currentDecibel db", style: TextStyle(fontSize: 30)),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // recording 중일경우, 녹음을 종료하고 soundData 정보를 저장한다.
          if (clip.isRecoding) {
            SoundData data = clip.finishRecoding();
            print("${data.date} : ${data.averageDecibel} / ${data.maxDecibel}");
            SqliteUtil.onAdd(data);
          }
          // 아닐 경우 녹음을 시작한다.
          else {
            clip.startRecoding();
          }
        },
        child: clip.isRecoding ? Icon(Icons.pause) : Icon(Icons.play_arrow),
      ),
    );
  }
}
