import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:mime/mime.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/utils/file_utils.dart';
import 'package:than_player/core/utils/path_scanner.dart';
import 'package:than_player/core/utils/platform_utils.dart';

class VideoScanner extends PathScanner<VideoFile> {
  @override
  bool isInclude(FileSystemEntity entry, String name) {
    final size = entry.file.lengthSync();
    // 1mb အောက် မလိုဘူး
    if (size < 1024 * 1024) return false;

    const videoExtensions = {
      'mp4',
      'mkv',
      'avi',
      'mov',
      'flv',
      'wmv',
      'webm',
      'm4v',
      '3gp',
    };
    final ext = name.extName.toLowerCase();
    if (videoExtensions.contains(ext)) {
      return true;
    }

    final mm = lookupMimeType(entry.path);
    if (mm == null) return false;
    if (mm.startsWith('video')) {
      return true;
    }
    return false;
  }

  @override
  Future<VideoFile?> processEntry(FileSystemEntity entry, String name) async {
    final dur = await PlatformUtils.getDuration(entry.path);
    return VideoFile(
      id: FileUtils.getFileIdSync(entry.path),
      name: name,
      path: entry.path,
      dirname: entry.parent.onlyName,
      date: entry.modifiedDate,
      size: entry.size,
      duration: dur,
    );
  }
}
