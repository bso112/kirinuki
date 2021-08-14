import 'package:flutter/foundation.dart';
import 'dart:async';

class Debouncer {
  Timer? _timer;
  final int delayInMs;

  Debouncer({required this.delayInMs});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delayInMs), action);
  }
}
