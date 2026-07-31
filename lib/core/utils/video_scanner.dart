import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/utils/file_utils.dart';
import 'package:than_player/core/utils/platform_utils.dart';

class VideoScanner {
  static const videoExtensions = {
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

  Future<List<VideoFile>> scan({List<String>? rootPath}) async {
    var roots = rootPath ?? await PlatformUtils.getScanRootPath();

    return await Isolate.run(() {
      List<VideoFile> list = [];

      for (var path in roots) {
        final dirs = <Directory>[Directory(path)];
        while (dirs.isNotEmpty) {
          final currentDir = dirs.removeLast();
          if (!currentDir.existsSync()) continue;

          try {
            final entries = currentDir.listSync(followLinks: false);

            for (var entry in entries) {
              if (entry is File) {
                final name = entry.getName();
                if (name.startsWith('.') || name.startsWith('Android')) {
                  continue;
                }
                final video = processEntry(entry, name);
                if (video == null) continue;
                list.add(video);
              } else if (entry is Directory) {
                dirs.add(entry.directory);
              }
            }
          } catch (e) {
            debugPrint('[VideoScanner:scan]: $e');
          }
        }
      }

      return list;
    });
  }

  static VideoFile? processEntry(FileSystemEntity entry, String name) {
    try {
      final size = entry.file.lengthSync();
      // 1mb အောက် မလိုဘူး
      if (size < 1024 * 1024) return null;

      final mm = lookupMimeType(entry.path);
      if (mm == null) return null;
      if (!mm.startsWith('video')) {
        return null;
      }
      return VideoFile(
        id: FileUtils.getFileIdSync(entry.path),
        name: name,
        path: entry.path,
        dirname: entry.parent.onlyName,
        date: entry.modifiedDate,
        size: entry.size,
      );
    } catch (e) {
      debugPrint('Dev: [VideoScanner:processEntry]: $e');
      return null;
    }
  }
}
