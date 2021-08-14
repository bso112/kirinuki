
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String text, void Function() onPressed) {
  final snackBar = SnackBar(
    content: Text(text),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: onPressed
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}