// ignore_for_file: implementation_imports

import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/foundation.dart';
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
          // 500 KB အောက် မထည့်ဘူး (1024 * 500)
          if (entry.size < (1024 * 500)) return null;

          final mm = lookupMimeType(entry.path);
          if (mm == null || !mm.startsWith('audio')) return null;

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

          try {
            if (!currentDir.existsSync()) continue;

            // listSync မှာ error တက်နိုင်တာမို့ try-catch ထဲထည့်ပါမည်
            final entries = currentDir.listSync(followLinks: false);

            for (var entry in entries) {
              final name = entry.getName();

              // Hidden files သို့မဟုတ် Android System folder များကို ကျော်မည်
              if (name.startsWith('.') || name.startsWith('Android')) continue;

              if (entry is File) {
                final audio = processEntry(entry, name);
                if (audio != null) list.add(audio);
              } else if (entry is Directory) {
                // Directory ဖြစ်မှသာ Sub-directory စာရင်းထဲပေါင်းမည်
                dirs.add(entry);
              }
            }
          } catch (e) {
            // Android storage permission ကြောင့် ဖတ်မရတဲ့ folder များကို skip လုပ်မည်
            debugPrint('[AudioScanner:listSync Exception]: $e');
          }
        }
      }

      return list;
    });
  }
}
