import 'dart:math';

import 'package:video_player/video_player.dart';

extension StringExt on String {
  String? toNullIfEmpty() {
    return isEmpty ? null : this;
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

extension ListExt<T> on List<T> {
  void forEachIndex(void Function(int, T) function) {
    for (int i = 0; i < length; ++i) {
      function(i, this[i]);
    }
  }
}
