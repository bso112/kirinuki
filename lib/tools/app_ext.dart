import 'dart:math';

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