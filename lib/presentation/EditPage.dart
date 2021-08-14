import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kirinuki/presentation/EditPageController.dart';
import 'package:kirinuki/route/app_pages.dart';
import 'package:kirinuki/widget/bouncing_icon_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

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
    _videoPlayerController.position.then((_){
      controller.videoPosition.value =
          (_videoPlayerController.value.position.inMilliseconds /
              _videoPlayerController.value.duration.inMilliseconds);
    });


    final iconColor = Colors.white;

    return Column(
      children: [
        Stack(
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Bouncing(
                    child: Icon(Icons.skip_previous, color: iconColor),
                    onTap: () {
                      final newPosition =
                          _videoPlayerController.value.position.inSeconds -
                              controller.skipInSecond.value;
                      _videoPlayerController
                          .seekTo(Duration(seconds: newPosition));
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
                      _videoPlayerController
                          .seekTo(Duration(seconds: newPosition));
                      print("newPos" + newPosition.toString());
                    }),
              ]),
            )
          ],
        ),
        Obx(() => LinearProgressIndicator(
              value: controller.videoPosition.value,
              backgroundColor: Colors.red.withOpacity(0.3),
              color: Colors.red,
            ))
      ],
    );
  }
}
