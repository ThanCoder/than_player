import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state_controller.dart';

class VideoBookmarkController {
  static VideoBookmarkController instance = VideoBookmarkController._();
  VideoBookmarkController._();
  factory VideoBookmarkController() => instance;

  final _store = CFBStore();
  final List<String> list = [];
  final _controller = StreamController<String>.broadcast();
  Stream<String> get stream => _controller.stream;

  Future<void> init(String path) async {
    list.clear();
    await _store.open(path);
    list.addAll(_store.getStringList('list'));
    _controller.add('');
  }

  void add(String id) {
    list.add(id);
    _store.put('list', list);
    _store.writeAll();
    _controller.add(id);
  }

  void remove(String id) {
    final index = list.indexWhere((e) => e == id);
    if (index == -1) return;
    list.removeAt(index);

    _store.put('list', list);
    _store.writeAll();
    _controller.add(id);
  }

  bool exists(String id) {
    return list.indexWhere((e) => e == id) != -1;
  }

  List<VideoFile> getVideoFiles() {
    List<VideoFile> res = [];
    for (var file in VideoStateController().state.list) {
      if (list.contains(file.id)) {
        res.add(file);
      }
    }
    return res;
  }
}
