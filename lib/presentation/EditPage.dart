import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:kirinuki/presentation/EditPageController.dart';
import 'package:kirinuki/presentation/widget/fill_track_shape.dart';
import 'package:kirinuki/presentation/widget/subtitle_dialog.dart';
import 'package:kirinuki/tools/lifecycle_callback.dart';
import 'package:kirinuki/tools/srt_generator.dart';
import 'package:kirinuki/widget/bouncing_icon_button.dart';
import 'package:kirinuki/tools/app_ext.dart';
import 'package:kirinuki/widget/widget_builder.dart';

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

  Widget _buildEditor() {
    return Container(
      color: Colors.grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMagnifySlider(),
          _buildEditNavigator(),
          _buildSubtitleBtn(),
          _buildSubtitleList(),
          Obx(() => controller.isSubtitleEditMode.value
              ? _buildSubtitleDeleteButton()
              : _buildSubmitBtn())
        ],
      ),
    );
  }

  Widget _buildMagnifySlider() {
    return SizedBox(
      height: 30,
      child: Obx(
        () => Slider.adaptive(
          value: controller.slideMagnification.value,
          min: 1,
          max: 5,
          onChanged: (value) {
            controller.slideMagnification.value = value;
          },
        ),
      ),
    );
  }

  CupertinoButton _buildSubtitleDeleteButton() {
    return CupertinoButton(
        child: Text(
          '삭제하기',
          style: TextStyle(color: Colors.white),
        ),
        color: Colors.red,
        onPressed: () {
          controller.subtitles
              .removeWhere((element) => controller.selectedSubtitles.contains(element));
          controller.isSubtitleEditMode.value = false;
        });
  }

  CupertinoButton _buildSubmitBtn() {
    return CupertinoButton(
        child: Text(
          '.srt 로 내보내기',
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

  Widget _buildEditNavigator() {
    ScrollController scrollController = ScrollController();

    final debouncer10 = Debouncer(delay: Duration(milliseconds: 10));
    //네비게이터 스크롤시 비디오 포지션 옮기기
    scrollController.addListener(() {
      if (controller.isVideoPlaying) return;
      debouncer10.call(() {
        final ratio = scrollController.offset / scrollController.position.maxScrollExtent;
        controller.seekTo(controller.videoDuration * ratio);
      });
    });

    return LifecycleCallback(
      onDispose: () {
        scrollController.dispose();
      },
      child: LayoutBuilder(builder: (_, constraint) {
        return AppWidgetBuilder(builder: (_) {
          final leftPadding = constraint.maxWidth / 2;

          double newScrollPos() {
            return controller.getVideoCurrentPositionRatio() *
                constraint.maxWidth *
                controller.slideMagnification.value;
          }

          //자동 스크롤
          ever(controller.videoPositionChanged, (_) {
            // if (!controller.isVideoPlaying) return;
            scrollController.jumpTo(newScrollPos());
          });

          ever(controller.slideMagnification, (_) {
            scrollController.jumpTo(newScrollPos());
          });

          return Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                    //controller.pauseVideo();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    child: Obx(() {
                      final videoWidth = constraint.maxWidth;
                      final sliderWidth = videoWidth * controller.slideMagnification.value;
                      final navigatorWidth = sliderWidth + constraint.maxWidth;

                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        color: Colors.black,
                        width: navigatorWidth,
                        height: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height: 30,
                                child: controller.videoDuration.inMilliseconds != 0
                                    ? _buildSubtitleBlock(
                                        scrollController.offset, sliderWidth, leftPadding)
                                    : Container()),
                            SizedBox(height: 5),
                            Expanded(
                              child: Container(
                                  color: Colors.yellow,
                                  width: sliderWidth,
                                  margin: EdgeInsets.only(left: leftPadding)),
                            )
                          ],
                        ),
                      );
                    })),
              ),
              Positioned(
                  left: constraint.maxWidth / 2,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.red,
                    width: 3,
                    height: constraint.maxHeight,
                  )),
            ],
          );
        });
      }),
    );
  }

  /// scrollX : 0 ~ sliderWidth
  /// sliderWitdh : 동영상바 길이
  /// leftPadding : 화면 너비의 절반
  Widget _buildSubtitleBlock(double scrollX, double sliderWidth, double leftPadding) {
    double getDragPosition(DragUpdateDetails detail) {
      return scrollX + detail.globalPosition.dx - leftPadding;
    }

    double getDragPositionRatio(DragUpdateDetails detail) {
      return getDragPosition(detail) / sliderWidth;
    }

    double getSubtitleWidth(Subtitle subtitle) {
      double subtitleRatio =
          (subtitle.end.inMilliseconds.toDouble() - subtitle.start.inMilliseconds.toDouble()) /
              controller.videoDuration.inMilliseconds.atLeast(1);
      return sliderWidth * subtitleRatio;
    }

    double getSubtitleOffsetLeftInGlobal(Subtitle subtitle) {
      double subtitleRatio =
          subtitle.start.inMilliseconds / controller.videoDuration.inMilliseconds.atLeast(1);
      return leftPadding + sliderWidth * subtitleRatio;
    }

    //자막 블록 양 옆의 핸들 넓이
    final handleWidth = 5.0;
    return Stack(
      children: controller.subtitles
          .map((element) => Positioned(
              left: getSubtitleOffsetLeftInGlobal(element),
              top: 0,
              bottom: 0,
              child: Row(
                children: [
                  GestureDetector(
                    onHorizontalDragUpdate: (detail) {
                      element.moveStartTo(controller.videoDuration * getDragPositionRatio(detail));
                      controller.subtitles.refresh();
                    },
                    child: Container(
                      color: Colors.red,
                      width: handleWidth,
                    ),
                  ),
                  GestureDetector(
                      onHorizontalDragUpdate: (detail) {
                        //TODO : 마이너스 타임라인도 인식하나? 확인필요
                        element.moveTo(Duration(
                            milliseconds: (controller.videoDuration.inMilliseconds *
                                    getDragPositionRatio(detail))
                                .toInt()));
                        controller.subtitles.refresh();
                      },
                      child: Container(
                          color: Colors.blue,
                          width: (getSubtitleWidth(element) - handleWidth * 2).atLeast(0),
                          height: double.infinity,
                          child: Center(child: Text(element.content, maxLines: 1)))),
                  GestureDetector(
                    onHorizontalDragUpdate: (detail) {
                      element.moveEndTo(controller.videoDuration * getDragPositionRatio(detail));
                      controller.subtitles.refresh();
                    },
                    child: Container(
                      color: Colors.red,
                      width: handleWidth,
                    ),
                  ),
                ],
              )))
          .toList(),
    );
  }

  Widget _buildSubtitle(Subtitle subtitle) {
    TextEditingController textFieldController = TextEditingController(text: subtitle.content);
    return LifecycleCallback(
      onDispose: () {
        textFieldController.dispose();
      },
      child: Obx(
        () => GestureDetector(
          child: Stack(
            children: [
              TextField(
                enabled: controller.isSubtitleEditMode.value,
                controller: textFieldController,
                onChanged: (value) {
                  subtitle.setContent(value);
                },
              ),
              controller.isSubtitleEditMode.value
                  ? Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Checkbox(
                        value: controller.selectedSubtitles.contains(subtitle),
                        onChanged: (isChecked) {
                          if (isChecked.toSafe()) {
                            controller.selectedSubtitles.add(subtitle);
                          } else {
                            controller.selectedSubtitles.remove(subtitle);
                          }
                        },
                      ))
                  : Container()
            ],
          ),
          onTap: () {
            controller.seekTo(subtitle.start);
          },
          onLongPress: () {
            controller.isSubtitleEditMode.value = true;
          },
        ),
      ),
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
              data: SliderTheme.of(context).copyWith(
                  trackShape: FillTrackShape(), thumbShape: RectangularSliderValueIndicatorShape()),
              child: controller.getVideoPlaySlider()),
        )
      ],
    );
  }
}
