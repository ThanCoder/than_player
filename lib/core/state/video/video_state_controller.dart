import 'dart:async';

import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state.dart';
import 'package:than_player/core/utils/video_scanner.dart';

class VideoStateController {
  static VideoStateController instance = VideoStateController._();
  VideoStateController._();
  factory VideoStateController() => instance;

  final _controller = StreamController<VideoState>.broadcast();
  Stream<VideoState> get stateStream => _controller.stream;
  VideoState _state = VideoState.empty();
  VideoState get state => _state;

  Future<void> init() async {}
  Future<void> scanList() async {
    try {
      _state = _state.copyWith(error: '', isLoading: true, list: []);
      _controller.add(_state);

      final list = await VideoScanner().scan();
      list.sortDate();
      _state = _state.copyWith(isLoading: false, list: list);
      _controller.add(_state);
    } catch (e) {
      _state = _state.copyWith(error: e.toString(), isLoading: false);
      _controller.add(_state);
    }
  }
}
