import 'dart:math';

import 'package:flutterapp/SoundData.dart';
import 'package:intl/intl.dart';

class SoundPager {
  List<int> decibelData = List<int>();
  bool isRecoding = false;

  void addSound(int decibel) {
    if (isRecoding) {
      decibelData.add(decibel);
    }
  }

  void startRecoding() {
    decibelData.clear();
    isRecoding = true;
  }

  SoundData finishRecoding() {
    var data = generateSoundData(parseDate(new DateTime.now()), decibelData);
    isRecoding = false;
    decibelData.clear();
    return data;
  }

  SoundData generateSoundData(String date, List<int> decibelData) {
    var maxDecibel =
        decibelData.reduce((value, element) => max(value, element));

    var averageDecibel =
        decibelData.reduce((value, element) => value + element) ~/
            decibelData.length;

    return SoundData(
        maxDecibel: maxDecibel, averageDecibel: averageDecibel, date: date);
  }
}
