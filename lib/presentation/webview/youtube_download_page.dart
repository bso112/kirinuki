
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kirinuki/tools/network.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';

class YoutubeDownloadPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => YoutubeDownloadPageState();
}

class YoutubeDownloadPageState extends State<YoutubeDownloadPage> {
  static const _youtubeDownloaderUrl = "https://www.y2mate.com/kr/youtube/";
  static const _albumName = 'Media';

  String currentUrl = "";

  @override
  void initState() {
    currentUrl = _youtubeDownloaderUrl + Get.arguments['videoCode'];
    requestPermission();
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
              downloadFile(url);
            }

            return NavigationDecision.prevent;
          },
        ),
      ),
    );
  }

  void requestPermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
  }
}
