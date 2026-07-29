import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg_android/than_pkg_android.dart';

class PlatformUtils {
  static Future<bool> genVideoThumbnail(
    String path,
    String outPath, {
    int width = 0,
    int height = 0,
    Duration time = const Duration(seconds: 1),
  }) async {
    if (Platform.isAndroid) {
      await ThanPkgAndroid.getInstance.videoHandler.saveThumbnail(
        path,
        outPath,
        width: width,
        height: height,
        time: time,
      );
      return true;
    }

    await ThanPkg.platform.genVideoThumbnail(
      pathList: [SrcDistType(src: path, dist: outPath)],
    );
    return true;
  }

  static Future<List<String>> getScanRootPath() async {
    final scanFolders = <String>[];
    if (Platform.isLinux) {
      scanFolders.add((await getApplicationDocumentsDirectory()).path);
      scanFolders.add((await getDownloadsDirectory())!.path);
      final homePath = Platform.environment['HOME'];
      if (homePath != null) {
        scanFolders.add(homePath.join('Music'));
        scanFolders.add(homePath.join('Videos'));
      }
    }
    if (Platform.isAndroid) {
      scanFolders.add(ThanPkg.android.app.getAppExternalPath());
    }
    return scanFolders;
  }

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
