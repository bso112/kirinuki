import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kirinuki/main.dart';
import 'package:kirinuki/presentation/EditPageController.dart';
import 'package:kirinuki/presentation/widget/fill_track_shape.dart';
import 'package:kirinuki/presentation/widget/follow_touch_widget.dart';
import 'package:kirinuki/presentation/widget/subtitle_dialog.dart';
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
  void initState() {
    super.initState();
  }

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
        child: Column(children: [_buildVideoPlayer(videoPath), Expanded(child: _buildEditor())]),
      ),
    );
  }

  double getSubtitleWidth(double sliderWidth, Subtitle subtitle) {
    double subtitleRatio =
        (subtitle.end.inMilliseconds.toDouble() - subtitle.start.inMilliseconds.toDouble()) /
            controller.videoDuration.inMilliseconds.atLeast(1);
    return sliderWidth * controller.slideMagnification.value * subtitleRatio;
  }

  double getSubtitleOffsetLeft(double sliderWidth, Subtitle subtitle) {
    double subtitleRatio =
        subtitle.start.inMilliseconds / controller.videoDuration.inMilliseconds.atLeast(1);
    return sliderWidth * controller.slideMagnification.value * subtitleRatio;
  }

  Widget _buildEditor() {
    return Container(
      color: Colors.grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMagnifySlider(),
          _buildSubtitleNavigator(),
          _buildSubtitleBtn(),
          _buildSubtitleList(),
          _buildSubmitBtn()
        ],
      ),
    );
  }

  Widget _buildMagnifySlider() {
    return SizedBox(
      height: 30,
      child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
              trackShape: FillTrackShape(),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0)),
          child: Obx(
            () => Slider(
              value: controller.slideMagnification.value,
              min: 1,
              max: 5,
              onChanged: (value) {
                controller.slideMagnification.value = value;
              },
            ),
          )),
    );
  }

  CupertinoButton _buildSubmitBtn() {
    return CupertinoButton(
        child: Text(
          'submit',
          style: TextStyle(color: Colors.black),
        ),
        color: Colors.white,
        onPressed: () {
          SrtGenerator.generate(controller.subtitles, 'sample');
        });
  }

  Widget _buildSubtitleList() {
    return Expanded(
      child: Container(
        color: Colors.blue,
        child: Obx(
          () => ListView.builder(
              itemCount: controller.subtitles.length,
              padding: EdgeInsets.only(top: 0),
              shrinkWrap: true,
              itemBuilder: (_, index) {
                return Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(10),
                    color: Colors.white,
                    child: _buildSubtitle(controller.subtitles[index]));
              }),
        ),
      ),
    );
  }

  Container _buildSubtitleBtn() {
    return Container(
      color: Colors.pink,
      margin: EdgeInsets.only(top: 5, left: 10, bottom: 5, right: 10),
      child: CupertinoButton(
        child: Text("자막 넣기"),
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => SubtitleDialog((subtitle) {
                    controller.addSubtitle(subtitle);
                  }));
        },
      ),
    );
  }

  Widget _buildSubtitleNavigator() {
    return Container(
      color: Colors.pink,
      height: 60,
      child: Column(
        children: [
          Container(
            height: 30,
            child: Obx(() =>
                controller.videoDuration.inMilliseconds != 0 ? _buildSubtitleBlock() : Container()),
          ),
          Container(color: Colors.yellow, height: 30)
        ],
      ),
    );
  }

  Widget _buildSubtitleBlock() {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Obx(
          () => Stack(
            children: controller.subtitles
                .map((element) => Positioned(
                    left: getSubtitleOffsetLeft(constraint.maxWidth, element),
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (dragUpdateDetails) {
                        final ratio = dragUpdateDetails.globalPosition.dx / constraint.maxWidth;
                        element.moveTo(Duration(
                            milliseconds:
                                (controller.getVideoDuration().inMilliseconds * ratio).toInt()));
                        controller.subtitles.refresh();
                      },
                      child: Container(
                          color: Colors.blue,
                          width: getSubtitleWidth(constraint.maxWidth, element)),
                    )))
                .toList(),
          ),
        );
      },
    );
  }

  // Widget _buildSubtitleBlock2() {
  //   return Obx(
  //     () => Stack(
  //       children: controller.subtitles
  //           .map((element) => Row(
  //                 crossAxisAlignment: CrossAxisAlignment.stretch,
  //                 children: [
  //                   GestureDetector(
  //                       child: Container(width: 10, color: Colors.purple),
  //                       onTap: () {
  //                         element.start = element.start.minus(Duration(milliseconds: 500));
  //                       }),
  //                   LayoutBuilder(
  //                     builder: (_, constraint) => Positioned(
  //                         left: getSubtitleOffsetLeft(constraint.maxWidth, element),
  //                         top: 0,
  //                         bottom: 0,
  //                         child: Container(
  //                             color: Colors.blue,
  //                             width: getSubtitleWidth(constraint.maxWidth, element) - 20)),
  //                   ),
  //                   GestureDetector(
  //                       child: Container(width: 10, color: Colors.purple),
  //                       onTap: () {
  //                         element.end += Duration(milliseconds: 1000);
  //                       })
  //                 ],
  //               ))
  //           .toList(),
  //     ),
  //   );
  // }

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
