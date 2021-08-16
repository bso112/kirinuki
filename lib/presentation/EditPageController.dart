import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_position.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';

class Subtitle {
  String content = "";
  final Duration start;
  final Duration end;

  Subtitle(this.content, this.start, this.end);
}

class EditPageController extends GetxController {
  var _videoPosition = Duration().obs;
  var _isVideoPlaying = false.obs;
  var skipInMs = 1000.obs;
  final subtitleList = List<Subtitle>.empty(growable: true).obs;

  get videoPosition => _videoPosition.value;

  get isVideoPlaying => _isVideoPlaying.value;

  late VideoPlayerController _videoPlayerController;
  late SubtitleController _subtitleController;

  Future<void> init(String videoPath) async {
    _videoPlayerController = VideoPlayerController.file(File(videoPath));
    _videoPlayerController.addListener(() {
      _videoPosition.value = _videoPlayerController.value.position;
      _isVideoPlaying.value = _videoPlayerController.value.isPlaying;
    });

    await _videoPlayerController.initialize();

    final documentPath = await getApplicationDocumentsDirectory();
    final subtitleDir = documentPath.path + '/sample.srt';
    _subtitleController = SubtitleController(
      subtitleUrl: subtitleDir,
      subtitleType: SubtitleType.webvtt,
    );
  }

  void addSubtitle(String content) {
    subtitleList.add(Subtitle(
        content, _videoPlayerController.value.position, _videoPlayerController.value.position));
  }

  Widget getVideoPlayer() {
    return AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: SubTitleWrapper(
            videoPlayerController: _videoPlayerController,
            subtitleController: _subtitleController,
            subtitleStyle: SubtitleStyle(
              position: SubtitlePosition(bottom: 10),
              textColor: Colors.white,
              hasBorder: true,
            ),
            videoChild: VideoPlayer(_videoPlayerController)));
  }

  Widget getVideoPlaySlider() {
    final debouncer100 = Debouncer(delay: Duration(milliseconds: 100));
    return Obx(
      () => Slider(
        value: _videoPosition.value.inMilliseconds.toDouble(),
        max: _videoPlayerController.value.duration.inMilliseconds.toDouble(),
        onChangeStart: (_) {
          _videoPlayerController.pause();
        },
        onChangeEnd: (_) {
          _videoPlayerController.play();
        },
        onChanged: (value) {
          final newPos = Duration(milliseconds: value.toInt());
          debouncer100.call(() {
            _videoPlayerController.seekTo(newPos);
          });
          _videoPosition.value = newPos;
        },
      ),
    );
  }

  void skipNext() {
    final newPos = _videoPlayerController.value.position.inMilliseconds + skipInMs.value;
    _videoPlayerController.seekTo(Duration(minutes: newPos));
  }

  void skipPrev() {
    final newPos = _videoPlayerController.value.position.inMilliseconds - skipInMs.value;
    _videoPlayerController.seekTo(Duration(minutes: newPos));
  }

  void clickPlay() {
    if (isVideoPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
    }
  }

  void seekTo(Duration position) {
    _videoPlayerController.seekTo(position);
  }
}
