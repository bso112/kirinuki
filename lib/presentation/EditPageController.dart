import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:kirinuki/presentation/widget/subtitle_video_view.dart';
import 'package:kirinuki/widget/srt_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_position.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';
import 'package:kirinuki/tools/app_ext.dart';

class Subtitle {
  String content = "";
  final Duration start;
  final Duration end;

  Subtitle({required this.content, required this.start, required this.end});
}

class EditPageController extends GetxController {
  var _videoPosition = Duration().obs;
  var _videoDuration = Duration().obs;
  var _isVideoPlaying = false.obs;
  var slideMagnification = 1.0.obs;
  var textStyle = TextStyle(color: Colors.black, fontSize: 30).obs;

  static const DEFAULT_SUBTITLE_WIDTH = Duration(seconds: 5);

  Rx<double?> subtitleLeft = 0.0.obs;
  Rx<double?> subtitleRight = 0.0.obs;
  Rx<double?> subtitleBottom = 0.5.obs;
  Rx<double?> subtitleTop = null.obs;

  var skipInMs = 1000.obs;
  final subtitles = List<Subtitle>.empty(growable: true).obs;

  Duration get videoPosition => _videoPosition.value;

  Duration get videoDuration => _videoDuration.value;

  bool get isVideoPlaying => _isVideoPlaying.value;




  late VideoPlayerController _videoPlayerController;

  Future<void> init(String videoPath) async {
    // _videoPlayerController = VideoPlayerController.file(File(videoPath));
    _videoPlayerController = VideoPlayerController.asset(videoPath);
    _videoPlayerController.addListener(() {
      _videoPosition.value = _videoPlayerController.value.position;
      _isVideoPlaying.value = _videoPlayerController.value.isPlaying;
    });

    await _videoPlayerController.initialize();
    _videoDuration.value = _videoPlayerController.value.duration;

    final documentPath = await getApplicationDocumentsDirectory();
    final subtitleDir = documentPath.path + '/sample.srt';
    subtitles.value = SrtParser.parse(await File(subtitleDir).readAsString());
  }

  void addSubtitle(String content) {
    subtitles.add(Subtitle(
        content: content,
        start: _videoPlayerController.value.position,
        end: _videoPlayerController.value.position + DEFAULT_SUBTITLE_WIDTH));
    subtitles.sort((a, b) {
      return a.start.compareTo(b.start);
    });
  }

  Widget getVideoPlayer() {
    return AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: SubtitleVideoView(
          videoPlayer: VideoPlayer(_videoPlayerController),
          subtitles: subtitles,
          textStyle: textStyle,
          left: subtitleLeft,
          top: subtitleTop,
          right: subtitleRight,
          bottom: subtitleBottom,
        ));
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
    var newPos = _videoPlayerController.value.position.inMilliseconds + skipInMs.value;
    newPos = newPos.clamp(0, _videoPlayerController.value.duration.inMilliseconds);
    _videoPlayerController.seekTo(Duration(milliseconds: newPos));
  }

  void skipPrev() {
    var newPos = _videoPlayerController.value.position.inMilliseconds - skipInMs.value;
    newPos = newPos.clamp(0, _videoPlayerController.value.duration.inMilliseconds);
    _videoPlayerController.seekTo(Duration(milliseconds: newPos));
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

  void seekToIndex(int subtitleIndex) {
    if (subtitleIndex >= subtitles.length) {
      return;
    }
    _videoPlayerController.seekTo(subtitles[subtitleIndex].start);
  }

  void seekToLast() {
    _videoPlayerController.seekTo(subtitles.last.start);
  }

  @override
  void onClose() {
    _videoPlayerController.dispose();
    super.onClose();
  }
}
