
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubtitleDialog extends StatefulWidget {
  final void Function(String) onConfirm;

  SubtitleDialog(this.onConfirm);

  @override
  State<StatefulWidget> createState() => _SubtitleDialogState();
}

class _SubtitleDialogState extends State<SubtitleDialog> {
  String _subtitle = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("자막"),
      content: TextField(
        decoration: InputDecoration(),
        onChanged: (str) {
          _subtitle = str;
        },
      ),
      actions: <Widget>[
        TextButton(
            child: const Text("추가"),
            onPressed: () {
              if (_subtitle != "") {
                widget.onConfirm(_subtitle);
              }
              Navigator.pop(context);
            })
      ],
    );
  }
}
