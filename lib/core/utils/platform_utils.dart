import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:than_pkg_android/than_pkg_android.dart';

class PlatformUtils {
  static Future<Duration> getDuration(String path) async {
    if (Platform.isAndroid) {
      final res = await ThanPkgAndroid.getInstance.videoHandler.getDuration(
        path,
      );
      return Duration(milliseconds: res ?? 0);
    }
    if (Platform.isLinux) {
      return await _getVideoDurationLinux(path);
    }
    throw UnsupportedError('[PlatformUtils:getDuration]: `platform error`');
  }
}

Future<Duration> _getVideoDurationLinux(String filePath) async {
  try {
    //ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 Supergirl\ \(2026\).mp4
    // Linux Built-in ffprobe command ကို ခေါ်ယူခြင်း
    final result = await Process.run('ffprobe', [
      '-v',
      'error',
      '-show_entries',
      'format=duration',
      '-of',
      'default=noprint_wrappers=1:nokey=1',
      filePath,
    ]);

    if (result.exitCode == 0) {
      final secondsString = result.stdout.toString().trim();
      final seconds = double.tryParse(secondsString) ?? 0.0;
      return Duration(milliseconds: (seconds * 1000).toInt());
    }
  } catch (e) {
    debugPrint('[_getVideoDurationLinux]: Error getting duration: $e');
  }
  return Duration.zero;
}
