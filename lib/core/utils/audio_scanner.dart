// ignore_for_file: implementation_imports

import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:mime/mime.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/models/audio_meta.dart';
import 'package:than_player/core/utils/file_utils.dart';
import 'package:than_player/core/utils/platform_utils.dart';

class AudioScanner {
  Future<List<AudioFile>> scan() async {
    final roots = await PlatformUtils.getScanRootPath();
    return await Isolate.run(() {
      List<AudioFile> list = [];

      AudioFile? processEntry(FileSystemEntity entry, String name) {
        try {
          // check size
          // 50 kb အောက် မထည့်ဘူး
          if (entry.size < (1024 * 500)) return null;

          final mm = lookupMimeType(entry.path);
          if (mm == null) return null;
          if (!mm.startsWith('audio')) {
            return null;
          }

          final meta = AudioMeta(entry.path);
          meta.openMeta();

          return AudioFile(
            id: FileUtils.getFileIdSync(entry.path),
            name: name,
            path: entry.path,
            dirname: entry.parent.onlyName,
            date: entry.modifiedDate,
            meta: meta,
            size: entry.size,
          );
        } catch (e) {
          debugPrint('[AudioScanner:processEntry]: $e');
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
              final audio = processEntry(entry, name);
              if (audio == null) continue;
              list.add(audio);
            } else if (entry is Directory) {}
            dirs.add(entry.directory);
          }
        }
      }

      return list;
    });
  }
}
