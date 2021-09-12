import 'dart:math';

import 'package:video_player/video_player.dart';

extension StringExt on String {
  String? toNullIfEmpty() {
    return isEmpty ? null : this;
  }
}

extension BooleanExt on bool? {
  bool toSafe(){
    return this ?? false;
  }
}

extension DoubleExt on double {
  double atLeast(double num) {
    return max(this, num);
  }
}

extension IntExt on int {
  int atLeast(int num) {
    return max(this, num);
  }
}

extension VideoPlayerControllerExt on VideoPlayerController {
  int getCurrentPosInRatio() {
    return value.position.inMilliseconds ~/ value.duration.inMilliseconds.atLeast(1);
  }
}

extension ListExt<T, R> on List<T> {
  void forEachIndex(void Function(int, T) function) {
    for (int i = 0; i < length; ++i) {
      function(i, this[i]);
    }
  }

  List<R> mapWithIndex<R>(R Function(int, T) function) {
    List<R> res = List.empty(growable: true);
    for (int i = 0; i < length; ++i) {
      res.add(function(i, this[i]));
    }
    return res;
  }
}

extension DurationExt on Duration {
  Duration minus(Duration other) {
    if (inMilliseconds - other.inMilliseconds < 0) {
      return Duration(milliseconds: 0);
    }
    return this - other;
  }

  Duration atLeast(Duration min) {
    if (this < min) {
      return min;
    }
    return this;
  }
}
