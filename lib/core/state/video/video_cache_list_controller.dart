import 'dart:io';

import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:than_player/core/models/video_file.dart';

class VideoCacheListController {
  static VideoCacheListController instance = VideoCacheListController._();
  VideoCacheListController._();
  factory VideoCacheListController() => instance;

  final _store = CFBStore();

  Future<void> init(String path) async {
    await _store.open(path);
  }

  void setList(List<VideoFile> outList) {
    try {
      final list = _store.getMapList('list');
      if (list.isEmpty) return;
      outList.clear();
      for (var map in list) {
        final file = VideoFile.fromMap(map);
        if (!File(file.path).existsSync()) continue;
        outList.add(file);
      }
    } catch (e) {
      debugPrint('[VideoCacheListController:setList]: $e');
    }
  }

  Future<void> addCacheList(List<VideoFile> list) async {
    try {
      final mapList = list.map((e) => e.toMap()).toList();
      await _store.putAndWriteAll('list', mapList);
    } catch (e) {
      debugPrint('[VideoCacheListController:addCacheList]: $e');
    }
  }
}
