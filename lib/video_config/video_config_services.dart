import 'package:cfb_store/cfb_store.dart';
import 'package:than_player/core/utils/platform_utils.dart';
import 'package:than_player/video_config/video_config.dart';

class VideoConfigServices {
  static VideoConfigServices instance = VideoConfigServices._();
  VideoConfigServices._();
  factory VideoConfigServices() => instance;
  final _store = CFBStore();

  Future<void> init(String path) async {
    await _store.open(path);
  }

  int getCurrentPosition(String id) {
    return _store.getInt('current-$id');
  }

  Future<void> setConfig(String id, VideoConfig config) async {
    _store.put('current-$id', config.current.inMilliseconds);
    _store.put('duration-$id', config.duration.inMilliseconds);

    await _store.writeAll();
  }

  Future<VideoConfig> getConfig(String id, String path) async {
    var dur = Duration(milliseconds: _store.getInt('duration-$id'));
    final cur = Duration(milliseconds: _store.getInt('current-$id'));

    if (dur == Duration.zero) {
      dur = await PlatformUtils.getDuration(path);
    }

    return VideoConfig(duration: dur, current: cur);
  }
}
