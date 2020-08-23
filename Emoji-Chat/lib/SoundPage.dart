import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterapp/SoundPager.dart';
import 'package:noise_meter/noise_meter.dart';

import 'SoundData.dart';
import 'SqliteUtil.dart';

/// 소음을 측정하는 화면입니다.
class SoundPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SoundPageState();
}

class SoundPageState extends State<StatefulWidget> {
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
  void dispose() {
    subscription.cancel();
    subscription = null;
    super.dispose();
  }

  @override
  void onData(NoiseReading sound) {
    setState(() {
      var decibel = sound.maxDecibel.toInt();
      this.currentDecibel = decibel;
      this.clip.addSound(decibel);
    });
    //if(!isSafeDecibel()) Vibration.vibrate(duration: 100);
  }

  bool isSafeDecibel() {
    DateTime now = DateTime.now();
    if (now.hour > 6 && now.hour < 22) {
      return currentDecibel < 77; //57
    } else {
      return currentDecibel < 72; //52
    }
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
      body: Center(
          child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: currentDecibel / 100,
              strokeWidth: 25,
              valueColor: AlwaysStoppedAnimation(
                  isSafeDecibel() ? Colors.blue : Colors.red),
            ),
          ),
          Text("$currentDecibel db", style: TextStyle(fontSize: 50)),
        ],
      )),
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
        child: clip.isRecoding ? Icon(Icons.stop) : Icon(Icons.play_arrow),
      ),
    );
  }
}
