import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:kirinuki/tools/util.dart';

class ImageThumb extends SliderComponentShape {
  final String path;
  final int width;
  final int height;
  ui.Image? _image;

  ImageThumb({required this.path, required this.width, required this.height}) {
    loadUiImage(path).then((value) {
      _image = value;
    });
  }

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(0, 0);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    final imageWidth = _image?.width ?? 10;
    final imageHeight = _image?.height ?? 10;

    Offset imageOffset = Offset(
      center.dx - (width / 2),
      center.dy - (height / 2),
    );

    Paint paint = Paint()..filterQuality = FilterQuality.high;

    if (_image != null) {
      canvas.drawImage(_image!, imageOffset, paint);
      log("드로우 이미지");
    } else {
      log("ImageThumb : 아직 이미지가 준비되지 않음");
    }
  }
}
