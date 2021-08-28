import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kirinuki/presentation/EditPageController.dart';
import 'package:kirinuki/presentation/widget/fill_track_shape.dart';
import 'package:kirinuki/tools/srt_generator.dart';
import 'package:kirinuki/widget/bouncing_icon_button.dart';
import 'package:kirinuki/tools/app_ext.dart';

class EditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late EditPageController controller = Get.find<EditPageController>();

  @override
  Widget build(BuildContext context) {
    // if (!(Get.arguments is XFile)) {
    //   Get.back();
    //   return Container();
    // }
    // final XFile video = Get.arguments;
    final videoPath = 'assets/video/test.mp4';

    return Scaffold(
      body: Container(
        child: Column(children: [
          _buildVideoPlayer(videoPath),
          SizedBox(height: 300, child: _buildEditor())
        ]),
      ),
    );
  }

  double getSubtitleWidth(double sliderWidth, Subtitle subtitle) {
    double subtitleRatio =
        (subtitle.end.inMilliseconds.toDouble() - subtitle.start.inMilliseconds.toDouble()) /
            controller.getVideoDuration().inMilliseconds.atLeast(1);
    return sliderWidth * controller.slideMagnification.value * subtitleRatio;
  }

  double getSubtitlePosition(double sliderWidth, Subtitle subtitle) {
    double subtitleRatio =
        subtitle.start.inMilliseconds / controller.getVideoDuration().inMilliseconds.atLeast(1);
    return sliderWidth * controller.slideMagnification.value * subtitleRatio;
  }

  Widget _buildEditor() {
  //  final sliderWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
       _buildSubtitleNavigator(200),
        _buildSubtitleBtn(),
        _buildSubtitleList(),
       _buildSubmitBtn()
      ],
    );
  }

  CupertinoButton _buildSubmitBtn() {
    return CupertinoButton(
        child: Text('submit'),
        onPressed: () {
          SrtGenerator.generate(controller.subtitles, 'sample');
        });
  }

  Expanded _buildSubtitleList() {
    return Expanded(
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
    ));
  }

  Container _buildSubtitleBtn() {
    return Container(
      color: Colors.pink,
      height: 50,
      margin: EdgeInsets.only(top: 5, left: 10, bottom: 5, right: 10),
      child: CupertinoButton(
        child: Text("자막 넣기"),
        onPressed: () {
          showDialog(context: context, builder: (_) => SubtitleDialog(controller.addSubtitle));
        },
      ),
    );
  }

  Container _buildSubtitleNavigator(double sliderWidth) {
    return Container(
        height: 30,
        child: Obx(
          () => Stack(
              children: controller.subtitles
                  .map((element) => Positioned(
                      left: getSubtitlePosition(sliderWidth, element),
                      child: Container(
                          color: Colors.blue, width: getSubtitleWidth(sliderWidth, element))))
                  .toList()),
        ));
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

class SubtitleDialog extends StatefulWidget {
  final void Function(String) addSubtitle;

  SubtitleDialog(this.addSubtitle);

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
        onChanged: (str){
          _subtitle = str;
        },
      ),
      actions: <Widget>[
        TextButton(
            child: const Text("추가"),
            onPressed: () {
              if (_subtitle != "") {
                widget.addSubtitle(_subtitle);
              }
              Navigator.pop(context);
            })
      ],
    );
  }
}
