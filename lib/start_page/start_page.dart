import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kirinuki/color.dart';
import 'package:kirinuki/start_page/start_page_controller.dart';
import 'package:kirinuki/tools/build_widget.dart';
import 'package:kirinuki/tools/network.dart';
import 'package:kirinuki/tools/youtube_downloader.dart';
import 'package:kirinuki/widget/bouncing_icon_button.dart';
import '../dimen.dart';

class StartPage extends StatelessWidget {
  final boundary = 400.0;

  Widget buildH1Text(String text) {
    return buildOutlineText(text,
        fontSize: h1, strokeColor: colorPrimary, strokeWidth: 3);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StartPageController());

    return Scaffold(
        body: Stack(children: [
      SizedBox.expand(
        child: Container(
          child: Container(
            margin: EdgeInsets.only(top: boundary),
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildH1Text("혹은\n파일로 불러오기"),
                SizedBox(height: 15),
                Bouncing(
                    child: Icon(Icons.folder_open, size: 80),
                    onTap: () {
                      print("asdasd");
                    })
              ],
            ),
          ),
        ),
      ),
      Container(
        height: boundary,
        decoration: BoxDecoration(
          color: Colors.blue.shade200,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(60),
              bottomRight: Radius.circular(60)),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          margin: EdgeInsets.only(bottom: 30),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Obx(() =>
                getImage(controller.videoInfo.value?.thumbnails.mediumResUrl)),
            buildH1Text("동영상 주소로 시작"),
            SizedBox(height: 15),
            Stack(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 5, color: colorPrimary),
                      color: Colors.white),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        style: TextStyle(fontSize: h1),
                        decoration: InputDecoration(border: InputBorder.none),
                        onSubmitted: (link) {
                          controller.getMetaData(link);
                        },
                      ),
                    ),
                  ),
                )
              ],
            )
          ]),
        ),
      )
    ]));
  }
}
