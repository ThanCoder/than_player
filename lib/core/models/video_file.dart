import 'package:than_player/core/utils/utils.dart';

class VideoFile {
  final String id;
  final String name;
  final String path;
  final String dirname;
  final DateTime date;
  final int size;
  final Duration? duration;
  const VideoFile({
    required this.id,
    required this.name,
    required this.path,
    required this.dirname,
    required this.date,
    required this.size,
    this.duration,
  });

  String get cacheName {
    return '$id-video.png';
  }

  String get cachCoverPath {
    return Utils.instance.getCachePath(cacheName);
  }

  @override
  String toString() {
    return 'VideoFile(id: $id, name: $name, path: $path, dirname: $dirname, date: $date, size: $size)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'path': path,
      'dirname': dirname,
      'date': date.millisecondsSinceEpoch,
      'size': size,
    };
  }

  factory VideoFile.fromMap(Map<String, dynamic> map) {
    return VideoFile(
      id: map['id'] as String,
      name: map['name'] as String,
      path: map['path'] as String,
      dirname: map['dirname'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      size: map['size'] as int,
    );
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
