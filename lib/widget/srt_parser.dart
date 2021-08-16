import 'package:kirinuki/presentation/EditPageController.dart';

abstract class SrtParser {
  static List<Subtitle> parse(String subtitlesContent) {
    final regExp = RegExp(
      r'((\d{2}):(\d{2}):(\d{2})\,(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})\,(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*(\r\n|\r|\n)(?:.*))',
      caseSensitive: false,
      multiLine: true,
    );

    final matches = regExp.allMatches(subtitlesContent).toList();
    final List<Subtitle> subtitleList = [];

    for (final RegExpMatch regExpMatch in matches) {
      final startTimeHours = int.parse(regExpMatch.group(2)!);
      final startTimeMinutes = int.parse(regExpMatch.group(3)!);
      final startTimeSeconds = int.parse(regExpMatch.group(4)!);
      final startTimeMilliseconds = int.parse(regExpMatch.group(5)!);

      final endTimeHours = int.parse(regExpMatch.group(7)!);
      final endTimeMinutes = int.parse(regExpMatch.group(8)!);
      final endTimeSeconds = int.parse(regExpMatch.group(9)!);
      final endTimeMilliseconds = int.parse(regExpMatch.group(10)!);
      final text = regExpMatch.group(11)!;
      
      final startTime = Duration(
          hours: startTimeHours,
          minutes: startTimeMinutes,
          seconds: startTimeSeconds,
          milliseconds: startTimeMilliseconds);
      final endTime = Duration(
          hours: endTimeHours,
          minutes: endTimeMinutes,
          seconds: endTimeSeconds,
          milliseconds: endTimeMilliseconds);

      subtitleList.add(
        Subtitle(start: startTime, end: endTime, content: text.trim()),
      );
    }

    return subtitleList;
  }
}
