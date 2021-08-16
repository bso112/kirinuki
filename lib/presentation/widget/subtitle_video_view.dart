import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../EditPageController.dart';

class SubtitleVideoView extends StatelessWidget {
  final VideoPlayer _videoPlayer;
  final RxList<Subtitle> _subtitles;
  final currentContent = ''.obs;

  SubtitleVideoView({required VideoPlayer videoPlayer, required RxList<Subtitle> subtitles})
      : _videoPlayer = videoPlayer,
        _subtitles = subtitles;

  void getCurrentSubtitle() {
    Subtitle? last;
    _subtitles.forEach((subtitle) {
      if (subtitle.start < _videoPlayer.controller.value.position) {
        last = subtitle;
      }
    });
    currentContent.value = last?.content ?? '';
  }

  @override
  Widget build(BuildContext context) {
    _videoPlayer.controller.addListener(() {
      getCurrentSubtitle();
    });

    return Stack(
      children: [
        _videoPlayer,
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(() => Container(
                color: Colors.red,
                child: Text(currentContent.value,
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white)))))
      ],
    );
  }
}
