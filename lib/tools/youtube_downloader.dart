import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeDownloader {
  final yt = YoutubeExplode();
  final savePath = '';

  Future<Video> getMetadata(String url) {
    return yt.videos.get("https://youtube.com/watch?v=Dpp1sIL1m5Q");
  }

  Future<Stream<List<int>>> getVideo(String url,
      {VideoQuality videoQuality = VideoQuality.medium480}) async {
    final manifest = await yt.videos.streamsClient.getManifest(url);
    late StreamInfo streamInfo;
    final filtered =
        manifest.muxed.where((e) => e.videoQuality == videoQuality);
    if (filtered.isEmpty) {
      streamInfo = manifest.muxed.withHighestBitrate();
    } else {
      streamInfo = filtered.first;
    }

    final stream = yt.videos.streamsClient.get(streamInfo);
    // Open a file for writing.
    var file = File(savePath);
    var fileStream = file.openWrite();

    // Pipe all the content of the stream into the file.
    await stream.pipe(fileStream);

    // Close the file.
    await fileStream.flush();
    await fileStream.close();

    return stream;
  }
}
