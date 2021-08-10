import 'package:flutter/cupertino.dart';

abstract class ScreenUtil {
  static double getDimen(double lp) {
    return lp;
  }

  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}
