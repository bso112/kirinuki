import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:kirinuki/presentation/EditPage.dart';
import 'package:kirinuki/presentation/widget/follow_touch_widget.dart';
import 'package:kirinuki/presentation/widget/subtitle_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  final videoController = VideoPlayerController.asset("assets/video/test.mp4");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Row(
          children: [
            Container(
              color: Colors.yellow,
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  Positioned(
                      left: 10,
                      top: 0,
                      bottom: 0,
                      right: 10,
                      child: Container(color: Colors.red,))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildList() {
    return ListView.builder(
        itemCount: 10,
        itemBuilder: (_, index) => Container(
              color: Colors.blue,
              height: 100,
              child: Text(
                "test",
                style: TextStyle(color: Colors.black),
              ),
            ));
  }

  _buildScroll() {
    return SingleChildScrollView(child: _buildList());
  }

  _buildVideo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.grey,
          height: 300,
          child: FutureBuilder(
              future: videoController.initialize(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  videoController.play();
                  return AspectRatio(
                      aspectRatio: videoController.value.aspectRatio,
                      child: VideoPlayer(videoController));
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
        TextButton(
          child: const Text("테스트", style: TextStyle(fontSize: 20)),
          onPressed: () {
            showDialog(context: context, builder: (_) => SubtitleDialog((_) {}));
          },
        ),
      ],
    );
  }
}
