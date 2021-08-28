import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../EditPageController.dart';

class SubtitleVideoView extends StatelessWidget {
  final VideoPlayer _videoPlayer;
  final RxList<Subtitle> _subtitles;
  final Rx<TextStyle> _textStyle;
  final currentContent = ''.obs;
  final Rx<double?> _top;
  final Rx<double?> _left;
  final Rx<double?> _right;
  final Rx<double?> _bottom;

  SubtitleVideoView(
      {required VideoPlayer videoPlayer,
      required RxList<Subtitle> subtitles,
      required Rx<TextStyle> textStyle,
      required Rx<double?> left,
      required Rx<double?> top,
      required Rx<double?> right,
      required Rx<double?> bottom})
      : _videoPlayer = videoPlayer,
        _subtitles = subtitles,
        _textStyle = textStyle,
        _left = left,
        _top = top,
        _right = right,
        _bottom = bottom;

  String getCurrentSubtitle() {
    final videoPosition = _videoPlayer.controller.value.position;
    for (int i = 0; i < _subtitles.length; ++i) {
      if (_subtitles[i].start < videoPosition && _subtitles[i].end > videoPosition) {
        return _subtitles[i].content;
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    _videoPlayer.controller.addListener(() {
      currentContent.value = getCurrentSubtitle();
    });

    return Stack(
      children: [
        _videoPlayer,
        Positioned(
            bottom: _bottom.value,
            left: _left.value,
            right: _right.value,
            top: _top.value,
            child: Obx(() => Container(
                child: Text(currentContent.value,
                    textAlign: TextAlign.center, style: _textStyle.value))))
      ],
    );
  }
}
