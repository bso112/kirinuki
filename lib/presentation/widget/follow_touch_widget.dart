import 'package:flutter/cupertino.dart';

class FollowTouch extends StatefulWidget {
  final Widget _child;
  bool applyX;
  bool applyY;

  FollowTouch({required Widget child, this.applyX = false, this.applyY = false}) : _child = child;

  @override
  State<StatefulWidget> createState() => _FollowTouchState();
}

class _FollowTouchState extends State<FollowTouch> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (dragUpdateDetails) {
        setState(() {
          _offset = dragUpdateDetails.localPosition;
        });
      },
      child: Stack(
        children: [
          Positioned(
              left: widget.applyX ? _offset.dx : 0,
              top: widget.applyY ? _offset.dy : 0,
              child: widget._child),
        ],
      ),
    );
  }
}
