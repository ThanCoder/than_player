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
    // check size
    // 50 kb အောက် မထည့်ဘူး
    if (entry.size < (1024 * 500)) return null;

    final mm = lookupMimeType(entry.path);
    if (mm == null) return null;
    if (mm.startsWith('audio')) {
      final meta = AudioMeta(entry.path);
      meta.openMeta();
      // 15s ထက်ကြီးရမယ်
      if (meta.duration != null && meta.duration!.inSeconds < 15) {
        return null;
      }
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
