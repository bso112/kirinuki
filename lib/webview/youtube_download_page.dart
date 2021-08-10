import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YoutubeDownloadPage extends StatefulWidget {
  String videoCode;

  YoutubeDownloadPage(this.videoCode);

  @override
  State<StatefulWidget> createState() => YoutubeDownloadPageState();
}

class YoutubeDownloadPageState extends State<YoutubeDownloadPage> {
  static const _youtubeDownloaderUrl = "https://www.y2mate.com/kr/youtube/";
  static const _albumName = 'Media';

  String currentUrl = "";

  @override
  void initState() {
    currentUrl = _youtubeDownloaderUrl + widget.videoCode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: currentUrl,
          navigationDelegate: (request) {
            final url = request.url;
            if (url.startsWith('https://redirector.googlevideo.com/') ||
                Uri.parse(url).queryParameters.containsKey('file')) {
              downloadVideo(url);
              //새창 열기
              setState(() {
                currentUrl = url;
              });
            }

            return NavigationDecision.prevent;
          },
        ),
      ),
    );
  }

  void showSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text('Yay! A SnackBar!'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void downloadVideo(String url) {
    GallerySaver.saveVideo(url, albumName: _albumName).then((success) {
      print("video save $success");
    });
  }
}
