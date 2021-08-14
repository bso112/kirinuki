import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Widget getImage(String? url) {
  return url == null
      ? Container()
      : FadeInImage.assetNetwork(
          fit: BoxFit.cover,
          placeholder: "assets/images/loading.gif",
          image: url);
}

//라운드 처리 이미지
Widget getRoundImage(String? url, {double radius = 25}) {
  return url == null
      ? ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(color: Colors.grey.shade500))
      : ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: FadeInImage.assetNetwork(
              fit: BoxFit.cover,
              placeholder: "assets/images/loading.gif",
              image: url),
        );
}

Future<String?> downloadFile(String url) async {
  final status = await Permission.storage.status;
  if (!status.isGranted) {
    return Future.error(Error());
  }
  final externalDir = await getExternalStorageDirectory();
  return FlutterDownloader.enqueue(
    url: url.toString(),
    savedDir: externalDir!.path,
    fileName: "download.mp4",
    showNotification: true,
    openFileFromNotification: true,
  );
}
