import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class YoutubeDownloadPage2 extends StatefulWidget {
  String videoCode;

  YoutubeDownloadPage2(this.videoCode);

  @override
  State<StatefulWidget> createState() => YoutubeDownloadPage2State();
}

class YoutubeDownloadPage2State extends State<YoutubeDownloadPage2> {
  static const _youtubeDownloaderUrl = "https://www.y2mate.com/kr/youtube/";
  static const _albumName = 'Media';

  String currentUrl = "";

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useOnDownloadStart: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  void initState() {
    currentUrl = _youtubeDownloaderUrl + widget.videoCode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(currentUrl)),
            initialOptions: options,
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var url = navigationAction.request.url!;
              if (url.host == 'redirector.googlevideo.com' ||
                  url.queryParameters.containsKey('file')) {
                final status = await Permission.storage.status;
                if (status.isGranted) {
                  final externalDir = await getExternalStorageDirectory();
                  FlutterDownloader.enqueue(
                    url: url.toString(),
                    savedDir: externalDir!.path,
                    fileName: "download.mp4",
                    showNotification: true,
                    openFileFromNotification: true,
                  ).onError((error, stackTrace) {
                    var i = 3;
                  });
                } else {
                  print('permission dineid');
                }

                return NavigationActionPolicy.ALLOW;
              }

              return NavigationActionPolicy.CANCEL;
            },
            onDownloadStart: (controller, url) async {
              var i = 3;
            }),
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
