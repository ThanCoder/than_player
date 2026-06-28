import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:mime/mime.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/utils/path_scanner.dart';

class VideoScanner extends PathScanner<VideoFile> {
  @override
  VideoFile? isInclude(FileSystemEntity entry, String name) {
    final mm = lookupMimeType(entry.path);
    if (mm == null) return null;
    if (mm.startsWith('video')) {
      return VideoFile(
        name: name,
        path: entry.path,
        dirname: entry.parent.onlyName,
        date: entry.modifiedDate,
        size: entry.size,
      );
    }
    return null;
  }
}
