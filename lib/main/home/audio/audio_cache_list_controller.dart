import 'dart:io';

import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:than_player/core/models/audio_file.dart';

class AudioCacheListController {
  static AudioCacheListController instance = AudioCacheListController._();
  AudioCacheListController._();
  factory AudioCacheListController() => instance;

  final _store = CFBStore();

  Future<void> init(String path) async {
    await _store.open(path);
  }

  void setList(List<AudioFile> outList) {
    try {
      final list = _store.getMapList('list');
      if (list.isEmpty) return;
      outList.clear();
      for (var map in list) {
        final file = AudioFile.fromMap(map);
        if (!File(file.path).existsSync()) continue;
        outList.add(file);
      }
    } catch (e) {
      debugPrint('[AudioCacheListController:setList]: $e');
    }
  }

  Future<void> addCacheList(List<AudioFile> list) async {
    try {
      final mapList = list.map((e) => e.toMap()).toList();
      await _store.putAndWriteAll('list', mapList);
    } catch (e) {
      debugPrint('[AudioCacheListController:addCacheList]: $e');
    }
  }
}
