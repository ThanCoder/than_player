import 'dart:io';
import 'dart:isolate';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:than_pkg/than_pkg.dart';

abstract class PathScanner<T> {
  @protected
  bool isExclude(FileSystemEntity entry, String name) =>
      name.startsWith('.') || name == 'Android';
  @protected
  T? isInclude(FileSystemEntity entry, String name);

  Future<List<T>> scan() async {
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
    return await Isolate.run(() {
      final list = <T>[];
      for (var path in scanFolders) {
        final dirs = <Directory>[Directory(path)];
        while (dirs.isNotEmpty) {
          final currentDir = dirs.removeLast();
          if (!currentDir.existsSync()) continue;
          for (var entry in currentDir.listSync(followLinks: false)) {
            if (isExclude(
              entry,
              FileSystemEntityCoreExtensions(entry).getName(),
            )) {
              continue;
            }

            if (entry.statSync().type == .file) {
              final res = isInclude(
                entry,
                FileSystemEntityCoreExtensions(entry).getName(),
              );
              if (res != null) {
                list.add(res);
              }
            }
            if (entry.statSync().type == .directory) {
              dirs.add(entry.directory);
            }
          }
        }
      }
      return list;
    });
  }
}


