import 'package:flutter/cupertino.dart';

class WidgetSwapper extends StatefulWidget {
  final Widget normal;
  final Widget onTabDown;

  WidgetSwapper({required this.normal, required this.onTabDown});

  @override
  State<StatefulWidget> createState() => _WidgetSwapperState();
}

class _WidgetSwapperState extends State<WidgetSwapper> {
  Widget? _currentWidget;

  @override
  void initState() {
    _currentWidget = widget.normal;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (_) {
          setState(() {
            _currentWidget = widget.onTabDown;
          });
        },
        onTapUp: (_) {
          setState(() {
            _currentWidget = widget.normal;
          });
        },
        child: _currentWidget);
  }
}
