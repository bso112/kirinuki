import 'package:get/get.dart';
import 'package:kirinuki/tools/youtube_downloader.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class StartPageController extends GetxController {
  final YoutubeDownloader youtube = YoutubeDownloader();

  Rx<Video?> videoInfo = Rx(null);

  void getMetaData(String link) {
    youtube.getMetadata(link).then((video) {
      videoInfo.value = video;
    });
  }
}
