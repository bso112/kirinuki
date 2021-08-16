import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as UI;
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

void showSnackbar(BuildContext context, String text,
    void Function() onPressed) {
  final snackBar = SnackBar(
    content: Text(text),
    action: SnackBarAction(label: 'Undo', onPressed: onPressed),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<UI.Image> loadUiImage(String imageAssetPath) async {
  final ByteData data = await rootBundle.load(imageAssetPath);
  final Completer<UI.Image> completer = Completer();

  UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image result) {
    return completer.complete(result);

  });

  return completer.future;
}

void log(String msg) {
  developer.log(msg, name: "manta");
}
