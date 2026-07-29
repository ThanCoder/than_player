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

  Future<List<VideoFile>> scan() async {
    final roots = await PlatformUtils.getScanRootPath();
    return await Isolate.run(() async {
      List<VideoFile> list = [];

      Future<VideoFile?> processEntry(
        FileSystemEntity entry,
        String name,
      ) async {
        try {
          final size = entry.file.lengthSync();
          // 1mb အောက် မလိုဘူး
          if (size < 1024 * 1024) return null;

          final ext = name.extName.toLowerCase();
          if (!videoExtensions.contains(ext)) {
            return null;
          }

          final mm = lookupMimeType(entry.path);
          if (mm == null) return null;
          if (!mm.startsWith('video')) {
            return null;
          }
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
        } catch (e) {
          debugPrint('[VideoScanner:processEntry]: $e');
          return null;
        }
      }

      for (var path in roots) {
        final dirs = <Directory>[Directory(path)];
        while (dirs.isNotEmpty) {
          final currentDir = dirs.removeLast();
          if (!currentDir.existsSync()) continue;
          for (var entry in currentDir.listSync(followLinks: false)) {
            if (entry is File) {
              final name = entry.getName();
              if (name.startsWith('.') || name.startsWith('Android')) continue;
              final video = await processEntry(entry, name);
              if (video == null) continue;
              list.add(video);
            } else if (entry is Directory) {
              dirs.add(entry.directory);
            }
          }
        }
      }

      return list;
    });
  }
}
