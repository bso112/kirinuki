import 'package:flutter/widgets.dart';

class LifecycleCallback extends StatefulWidget {
  final Function? onInit;
  final Function? onDispose;
  final Widget child;

  LifecycleCallback({this.onInit, this.onDispose, required this.child});

  @override
  State<StatefulWidget> createState() => _LifecycleCallbackState();
}

class _LifecycleCallbackState extends State<LifecycleCallback> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    widget.onInit?.call();
    super.initState();
  }



  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }
}
