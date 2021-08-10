import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Bouncing extends StatefulWidget {
  final Widget child;
  final Function? onTap;

  Bouncing({required this.child, this.onTap});

  @override
  State<Bouncing> createState() => _BouncingState();
}

class _BouncingState extends State<Bouncing> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 80),
    vsync: this,
  );

  late final Animation<double> _animation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.2), weight: 30),
    TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 0.8), weight: 40),
    TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1), weight: 30),
  ]).animate(_controller);

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call();
        _controller.reset();
        _controller.forward();
      },
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}
