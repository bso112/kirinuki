import 'package:flutter/foundation.dart';
import 'dart:async';

class AppDebouncer {
  Timer? _timer;
  final int delayInMs;

  AppDebouncer({required this.delayInMs});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delayInMs), action);
  }
}
