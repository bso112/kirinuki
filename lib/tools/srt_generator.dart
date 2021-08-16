import 'dart:io';

import 'package:kirinuki/presentation/EditPageController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kirinuki/tools/app_ext.dart';

abstract class SrtGenerator {
  static String formatAsSRT(int sequence, Subtitle subtitle) {
    String format(int number, {int digit = 2}) {
      final str = number.toString();
      var placeHolder = '';
      for (int i = 0; i < digit - str.length; ++i) {
        placeHolder += '0';
      }
      return placeHolder + str;
    }

    String durationToTimeStamp(Duration duration) {
      final hour = duration.inHours;
      final minute = duration.inMinutes % 60;
      final second = duration.inSeconds % 60;
      final ms = duration.inMilliseconds % 100;
      return '${format(hour)}:${format(minute)}:${format(second)},${format(ms, digit: 3)}';
    }

    return '$sequence\n${durationToTimeStamp(subtitle.start)} --> ${durationToTimeStamp(subtitle.end)}\n${subtitle.content}\n\n';
  }

  static void generate(List<Subtitle> subtitles, String fileName) async {
    final path = await getApplicationDocumentsDirectory();
    final file = File('${path.path}/$fileName.srt');
    var toWrite = '';
    subtitles.forEachIndex((index, element) {
      toWrite += formatAsSRT(index, element);
    });
    file.writeAsString(toWrite).then((file) async {
      final result = await File(file.path).readAsString();
      print('SRT generated : \n$result');
    }).onError((error, stackTrace) {
      print(error);
    });
  }
}
