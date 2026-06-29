import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:than_player/core/utils/utils.dart';

class VideoFile {
  final String name;
  final String path;
  final String dirname;
  final DateTime date;
  final int size;
  const VideoFile({
    required this.name,
    required this.path,
    required this.dirname,
    required this.date,
    required this.size,
  });

  String get cacheName {
    final digest = md5.convert(utf8.encode(name.onlyName));
    return '${digest.toString()}-video.png';
  }

  String get cachCoverPath {
    return Utils.instance.getCachePath(cacheName);
  }
}

extension VideoFileExt on List<VideoFile> {
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
