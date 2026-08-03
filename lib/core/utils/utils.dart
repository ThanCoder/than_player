import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:than_pkg_android/than_pkg_android.dart';
import 'package:than_player/extensions/str_exts.dart';

class Utils {
  static Utils instance = Utils._();
  Utils._();
  factory Utils() => instance;

  late Directory cacheDir;
  late String configPath;
  late PackageInfo packageInfo;
  late String androidRootDirPath;

  Future<void> init() async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final configDir = await getApplicationSupportDirectory();

      this.cacheDir = cacheDir;
      final cfDir = Directory(configDir.path.join('config'));
      if (!cfDir.existsSync()) {
        cfDir.createSync();
      }
      configPath = cfDir.path;
      packageInfo = await PackageInfo.fromPlatform();

      if (Platform.isAndroid) {
        final path = ThanPkgAndroid.getInstance.pathHandler
            .getDeviceStoragePath();
        androidRootDirPath = PathBuf(
          path,
        ).join('.${packageInfo.packageName}').path;
      }
    } catch (e) {
      debugPrint('[Utils:init]: $e');
    }
  }

  String getCachePath([String? name]) {
    if (!cacheDir.existsSync()) {
      cacheDir.createSync();
    }
    if (name == null) return cacheDir.path;
    return cacheDir.path.join(name);
  }

  String getConfigPath([String? name]) {
    if (name == null) return configPath;
    return configPath.join(name);
  }

  String getExternalConfigPath([String? name]) {
    var root = configPath;
    try {
      if (Platform.isAndroid) {
        final dir = PathBuf(androidRootDirPath).join('config').directory;
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        root = dir.path;
      }
    } catch (e) {
      debugPrint('[Utils:getExternalConfigPath]: $e');
    }
    if (name == null) return root;

    return root.join(name);
  }

  /// ### Return -> [(count,size)]
  Future<(int, int)?> getFolderInfo(Directory dir) async {
    if (!dir.existsSync()) return null;
    return await Isolate.run<(int, int)?>(() {
      try {
        int size = 0;
        int count = 0;
        for (var entry in dir.listSync(recursive: true)) {
          if (entry.isFile) {
            size += entry.size;
          }
          count++;
        }
        return (count, size);
      } catch (e) {
        debugPrint('[Utils:deleteDir]: $e');
        return null;
      }
    });
  }

  Future<bool> deleteFolder(Directory dir) async {
    if (!dir.existsSync()) return false;
    return await Isolate.run(() {
      try {
        dir.deleteSync(recursive: true);
        dir.createSync();
        return true;
      } catch (e) {
        debugPrint('[Utils:deleteDir]: $e');
        return false;
      }
    });
  }
}
