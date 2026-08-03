import 'package:than_player/core/models/audio_meta.dart';

class AudioFile {
  final String name;
  final String id;
  final String path;
  final String dirname;
  final DateTime date;
  final AudioMeta meta;
  final int size;
  final String cacheCoverPath;
  const AudioFile({
    required this.id,
    required this.name,
    required this.path,
    required this.dirname,
    required this.date,
    required this.meta,
    required this.size,
    required this.cacheCoverPath,
  });

  String get autoTitle {
    return meta.title.isNotEmpty ? meta.title : name;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'id': id,
      'path': path,
      'dirname': dirname,
      'date': date.millisecondsSinceEpoch,
      'meta': meta.toMap(),
      'size': size,
      'cacheCoverPath': cacheCoverPath,
    };
  }

  factory AudioFile.fromMap(Map<String, dynamic> map) {
    return AudioFile(
      name: map['name'] as String,
      id: map['id'] as String,
      path: map['path'] as String,
      dirname: map['dirname'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      meta: AudioMeta.fromMap(map['meta'] as Map<String, dynamic>),
      size: map['size'] as int,
      cacheCoverPath: map['cacheCoverPath'] ?? '',
    );
  }
}

extension AudioFileExt on List<AudioFile> {
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
