import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static Utils instance = Utils._();
  Utils._();
  factory Utils() => instance;

  late String cachePath;
  late String configPath;
  late PackageInfo packageInfo;

  Future<void> init() async {
    final cacheDir = await getApplicationCacheDirectory();
    final configDir = await getApplicationSupportDirectory();
    cachePath = cacheDir.path;
    final cfDir = Directory(configDir.path.join('config'));
    if (!cfDir.existsSync()) {
      cfDir.createSync();
    }
    configPath = cfDir.path;
    packageInfo = await PackageInfo.fromPlatform();
  }

  String getCachePath([String? name]) {
    if (name == null) return cachePath;
    return cachePath.join(name);
  }

  String getConfigPath([String? name]) {
    if (name == null) return configPath;
    return configPath.join(name);
  }
}
