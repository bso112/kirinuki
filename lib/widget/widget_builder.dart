
import 'package:flutter/cupertino.dart';

class AppWidgetBuilder extends StatelessWidget{
  final Widget Function(BuildContext context) builder;

  AppWidgetBuilder({required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }

}