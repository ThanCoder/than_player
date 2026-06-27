import 'package:than_player/core/models/audio_meta.dart';

class AudioFile {
  final String name;
  final String path;
  final String dirname;
  final DateTime date;
  final AudioMeta meta;
  AudioFile({
    required this.name,
    required this.path,
    required this.dirname,
    required this.date,
    required this.meta,
  });
}

extension AudioFileExt on List<AudioFile> {
  void sortDate({bool isNewest = true}) {
    sort((a, b) {
      if (isNewest) {
        return b.date.millisecondsSinceEpoch.compareTo(
          a.date.millisecondsSinceEpoch,
        );
      } else {
        return a.date.millisecondsSinceEpoch.compareTo(
          b.date.millisecondsSinceEpoch,
        );
      }
    });
  }
}
