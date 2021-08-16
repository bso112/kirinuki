import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kirinuki/presentation/EditPageController.dart';
import 'package:kirinuki/presentation/widget/fill_track_shape.dart';
import 'package:kirinuki/tools/srt_generator.dart';
import 'package:kirinuki/widget/bouncing_icon_button.dart';

class EditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late EditPageController controller = Get.find<EditPageController>();

  @override
  Widget build(BuildContext context) {
    if (!(Get.arguments is XFile)) {
      Get.back();
      return Container();
    }
    final XFile video = Get.arguments;

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(children: [
            Flexible(flex: 5, child: _buildVideoPlayer(video.path)),
            Flexible(flex: 6, child: _buildEditor())
          ]),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 30,
          margin: EdgeInsets.only(top: 5, left: 10, bottom: 5, right: 10),
          decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.black),
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
              onSubmitted: (value) {
                controller.addSubtitle(value);
              },
            ),
          ),
        ),
        Expanded(
            child: Container(
          color: Colors.grey.shade400,
          child: Obx(
            () => ListView.builder(
                itemCount: controller.subtitles.length,
                itemBuilder: (_, index) {
                  return Container(
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(10),
                      color: Colors.white,
                      child: _buildSubtitle(controller.subtitles[index]));
                }),
          ),
        )),
        CupertinoButton(
            child: Text('submit'),
            onPressed: () {
              SrtGenerator.generate(controller.subtitles,'sample');
            })
      ],
    );
  }

  Widget _buildSubtitle(Subtitle subtitle) {
    return GestureDetector(
      child: Text(subtitle.content),
      onTap: () {
        controller.seekTo(subtitle.start);
      },
    );
  }

  Widget _buildVideoPlayer(String videoPath) {
    final iconColor = Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.grey,
          height: 200,
          child: FutureBuilder(
            future: controller.init(videoPath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return controller.getVideoPlayer();
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          color: Colors.black.withOpacity(0.8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Bouncing(
                child: Icon(Icons.skip_previous, color: iconColor),
                onTap: () {
                  controller.skipNext();
                }),
            Obx(
              () => Bouncing(
                  child: controller.isVideoPlaying
                      ? Icon(Icons.stop, color: iconColor)
                      : Icon(Icons.play_arrow, color: iconColor),
                  onTap: () {
                    controller.clickPlay();
                  }),
            ),
            Bouncing(
                child: Icon(Icons.skip_next, color: iconColor),
                onTap: () {
                  controller.skipPrev();
                }),
          ]),
        ),
        Container(
          height: 20,
          child: SliderTheme(
              data: SliderTheme.of(context).copyWith(trackShape: FillTrackShape()),
              child: controller.getVideoPlaySlider()),
        )
      ],
    );
  }
}
