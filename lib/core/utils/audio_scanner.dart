// ignore_for_file: implementation_imports

import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:mime/mime.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/models/audio_meta.dart';
import 'package:than_player/core/utils/path_scanner.dart';

class AudioScanner extends PathScanner<AudioFile> {
  @override
  AudioFile? isInclude(FileSystemEntity entry, String name) {
    final mm = lookupMimeType(entry.path);
    if (mm == null) null;
    if (mm != null && mm.startsWith('audio')) {
      final meta = AudioMeta(entry.path);
      meta.openMeta();
      
      return AudioFile(
        name: name,
        path: entry.path,
        dirname: entry.parent.onlyName,
        date: entry.modifiedDate,
        meta: meta,
      );
    }
    return null;
  }
}
