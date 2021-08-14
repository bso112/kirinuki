import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kirinuki/presentation/EditPageController.dart';
import 'package:kirinuki/presentation/widget/custom_slider.dart';
import 'package:kirinuki/route/app_pages.dart';
import 'package:kirinuki/tools/debouncer.dart';
import 'package:kirinuki/widget/bouncing_icon_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:kirinuki/tools/app_ext.dart';

class EditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late VideoPlayerController _videoPlayerController;
  late EditPageController controller = Get.find<EditPageController>();

  @override
  void initState() {
    if (!(Get.arguments is XFile)) {
      Get.back();
      return;
    }
    final XFile video = Get.arguments;
    _videoPlayerController = VideoPlayerController.file(File(video.path));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(children: [_buildVideoPlayer()]),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    double _getCurrentPosition() {
      return _videoPlayerController.value.position.inMilliseconds /
          _videoPlayerController.value.duration.inMilliseconds.atLeast(1);
    }

    _videoPlayerController.position.then((_) {
      controller.videoPosition.value = _getCurrentPosition();
    });

    final iconColor = Colors.white;
    final debouncer100 = Debouncer(delayInMs: 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder(
          future: _videoPlayerController.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController));
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          color: Colors.black.withOpacity(0.8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Bouncing(
                child: Icon(Icons.skip_previous, color: iconColor),
                onTap: () {
                  final newPosition =
                      _videoPlayerController.value.position.inSeconds -
                          controller.skipInSecond.value;
                  _videoPlayerController.seekTo(Duration(seconds: newPosition));
                  print("newPos" + newPosition.toString());
                }),
            Obx(
              () => Bouncing(
                  child: controller.isVideoPlaying.value
                      ? Icon(Icons.stop, color: iconColor)
                      : Icon(Icons.play_arrow, color: iconColor),
                  onTap: () {
                    final onControlEnd = (value) {
                      controller.isVideoPlaying.value =
                          _videoPlayerController.value.isPlaying;
                    };
                    if (_videoPlayerController.value.isPlaying) {
                      _videoPlayerController.pause().then(onControlEnd);
                    } else {
                      _videoPlayerController.play().then(onControlEnd);
                    }
                  }),
            ),
            Bouncing(
                child: Icon(Icons.skip_next, color: iconColor),
                onTap: () {
                  final newPosition =
                      _videoPlayerController.value.position.inSeconds +
                          controller.skipInSecond.value;
                  _videoPlayerController.seekTo(Duration(seconds: newPosition));
                  print("newPos" + newPosition.toString());
                }),
          ]),
        ),
        Container(
          height: 20,
          child: Obx(() => SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbColor: Colors.transparent,
              thumbShape: SliderComponentShape.noThumb,
              trackShape: FillTrackShape()
            ),
            child: Slider(
                  value: controller.videoPosition.value,
                  max: 1,
                  onChanged: (value) {
                    debouncer100.run(() {
                      _videoPlayerController.seekTo(Duration(
                          milliseconds: (_videoPlayerController
                                      .value.duration.inMilliseconds *
                                  value)
                              .toInt()));
                    });
                    controller.videoPosition.value = value;
                  },
                ),
          )),
        )
      ],
    );
  }
}
