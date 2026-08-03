import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/widgets.dart';
import 'package:than_player/core/models/audio_file.dart';

class AudioBlocklistController {
  static AudioBlocklistController instance = AudioBlocklistController._();
  AudioBlocklistController._();
  factory AudioBlocklistController() => instance;

  final _store = CFBStore();
  final List<AudioFile> list = [];
  final _controller = StreamController<AudioFile>.broadcast();
  Stream<AudioFile> get stream => _controller.stream;

  Future<void> init(String path) async {
    list.clear();
    await _store.open(path);
    final mapList = _store.getMapList('map-list');
    list.addAll(mapList.map((e) => AudioFile.fromMap(e)));
  }

  void add(AudioFile file) {
    try {
      list.add(file);
      final mapList = list.map((e) => e.toMap()).toList();
      _store.put('map-list', mapList);
      _store.writeAll();
      _controller.add(file);
    } catch (e) {
      debugPrint('[AudioBlocklistController:add]: $e');
    }
  }

  void remove(AudioFile file) {
    final index = list.indexWhere((e) => e.id == file.id);
    if (index == -1) return;
    list.removeAt(index);

    final mapList = list.map((e) => e.toMap()).toList();
    _store.put('map-list', mapList);
    _store.writeAll();
    _controller.add(file);
  }

  bool exists(AudioFile file) {
    return list.indexWhere((e) => e.id == file.id) != -1;
  }

  int getSongIndexById(String id) {
    return list.indexWhere((e) => e.id == id);
  }
}
