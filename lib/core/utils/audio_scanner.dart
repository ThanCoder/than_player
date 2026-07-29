// ignore_for_file: implementation_imports

import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:mime/mime.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/models/audio_meta.dart';
import 'package:than_player/core/utils/file_utils.dart';
import 'package:than_player/core/utils/path_scanner.dart';

class AudioScanner extends PathScanner<AudioFile> {
  @override
  bool isInclude(FileSystemEntity entry, String name) {
    // check size
    // 50 kb အောက် မထည့်ဘူး
    if (entry.size < (1024 * 500)) return false;

    final mm = lookupMimeType(entry.path);
    if (mm == null) return false;
    if (mm.startsWith('audio')) {
      return true;
    }
    return false;
  }

  @override
  Future<AudioFile?> processEntry(FileSystemEntity entry, String name) async {
    try {
      final meta = AudioMeta(entry.path);
      meta.openMeta();

      return AudioFile(
        id: await FileUtils.getFileId(entry.path),
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
}
