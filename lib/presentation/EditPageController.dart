import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:kirinuki/presentation/widget/subtitle_video_view.dart';
import 'package:kirinuki/widget/srt_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:kirinuki/tools/app_ext.dart';

class Subtitle {
  var _content = "".obs;
  Duration _start;
  Duration _end;

  Subtitle({required String content, required start, required end})
      : _start = start,
        _end = end {
    _content.value = content;
  }

  String get content => _content.value;

  Duration get start => _start;

  Duration get end => _end;

  void setContent(String str) {
    _content.value = str;
  }

  void translate(Duration amount) {
    _start += amount;
    _end += amount;
  }

  //
  // void moveTo(Duration position){
  //   final duration = getLength();
  //   start = position - duration;
  //   end = start + duration;
  // }

  void moveTo(Duration position) {
    final duration = getLength();
    _start =
        Duration(milliseconds: (position.inMilliseconds - duration.inMilliseconds / 2).toInt());
    _end = start + duration;
  }

  Duration getLength() {
    return end - start;
  }

  void moveStartTo(Duration position) {
    _start = position;
    if (_start > _end) {
      _start = _end;
    }
  }

  void moveEndTo(Duration position) {
    _end = position;
    if (_end < _start) {
      _end = _start;
    }
  }
}

class EditPageController extends GetxController {
  var _videoPosition = Duration().obs;
  var _videoDuration = Duration().obs;
  var _isVideoPlaying = false.obs;
  var slideMagnification = 1.0.obs;
  var subtitleBlockDragLocalX = 0.0.obs;
  var textStyle = TextStyle(color: Colors.black, fontSize: 30).obs;
  var isSubtitleEditMode = false.obs;
  final selectedSubtitles = Set<Subtitle>().obs;

  static const DEFAULT_SUBTITLE_WIDTH = Duration(seconds: 5);

  Rx<double?> subtitleLeft = 0.0.obs;
  Rx<double?> subtitleRight = 0.0.obs;
  Rx<double?> subtitleBottom = 0.5.obs;
  Rx<double?> subtitleTop = null.obs;

  var skipInMs = 1000.obs;

  //이걸 우선순위큐로 하면 좋은데..
  final subtitles = List<Subtitle>.empty(growable: true).obs;

  Rx<Duration> get videoPositionChanged => _videoPosition;

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
    final debouncer10 = Debouncer(delay: Duration(milliseconds: 10));
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
          debouncer10.call(() {
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

  void seekToSubtitle(int subtitleIndex) {
    if (subtitleIndex >= subtitles.length) {
      return;
    }
    _videoPlayerController.seekTo(subtitles[subtitleIndex].start);
  }

  void seekToLast() {
    _videoPlayerController.seekTo(subtitles.last.start);
  }

  double getVideoPositionRatio(Duration position) {
    return position.inMilliseconds /
        _videoPlayerController.value.duration.inMilliseconds.atLeast(1);
  }

  double getVideoCurrentPositionRatio() {
    return videoPosition.inMilliseconds /
        _videoPlayerController.value.duration.inMilliseconds.atLeast(1);
  }

  void pauseVideo() {
    _videoPlayerController.pause();
  }

  void playVideo() {
    _videoPlayerController.play();
  }

  @override
  void onClose() {
    _videoPlayerController.dispose();
    super.onClose();
  }
}
