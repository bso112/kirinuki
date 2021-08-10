import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'font.dart';

Widget buildOutlineText(String text,
    {TextAlign align = TextAlign.center,
      String fontFamily = oneMobile,
      double fontSize = 20,
      double strokeWidth = 6,
      Color strokeColor = Colors.blue,
    }) {
  return Stack(
    children: <Widget>[
      // Stroked text as border.
      Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = strokeColor,
        ),
      ),
      // Solid text as fill.
      Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
    ],
  );
}
