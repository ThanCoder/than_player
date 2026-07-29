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

  bool isInclude(FileSystemEntity entry, String name);

  Future<T?> processEntry(FileSystemEntity entry, String name);

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

    final matchedEntries = await Isolate.run(() {
      final rawList = <FileSystemEntity>[];

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

            if (entry is File) {
              if (isInclude(
                entry,
                FileSystemEntityCoreExtensions(entry).getName(),
              )) {
                rawList.add(entry);
              }
            } else if (entry is Directory) {
              dirs.add(entry.directory);
            }
          }
        }
      }
      return rawList;
    });

    final res = await Future.wait(
      matchedEntries.map((e) {
        final name = FileSystemEntityCoreExtensions(e).getName();
        return processEntry(e, name);
      }),
    );
    return res.whereType<T>().toList();
  }
}
