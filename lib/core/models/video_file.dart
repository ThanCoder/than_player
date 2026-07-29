import 'package:than_player/core/utils/utils.dart';

class VideoFile {
  final String id;
  final String name;
  final String path;
  final String dirname;
  final DateTime date;
  final int size;
  final Duration duration;
  const VideoFile({
    required this.name,
    required this.path,
    required this.dirname,
    required this.date,
    required this.size,
    required this.id, required this.duration,
  });

  String get cacheName {
    return '$id-video.png';
  }

  String get cachCoverPath {
    return Utils.instance.getCachePath(cacheName);
  }
}

extension VideoFileExt on List<VideoFile> {
  void sortName({bool isA2Z = true}) {
    sort((a, b) {
      if (isA2Z) {
        return a.name.compareTo(b.name);
      } else {
        return b.name.compareTo(a.name);
      }
    });
  }

  void sortSize({bool smToBig = true}) {
    sort((a, b) {
      if (smToBig) {
        return a.size.compareTo(b.size);
      } else {
        return b.size.compareTo(a.size);
      }
    });
  }

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
