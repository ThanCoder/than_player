import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/core/state/audio/my_audio_handler.dart';
import 'package:than_player/core/utils/audio_scanner.dart';
import 'package:than_player/core/utils/utils.dart';

class AudioStateController {
  static AudioStateController instance = AudioStateController._();
  AudioStateController._();
  factory AudioStateController() => instance;

  final _controller = StreamController<AudioState>.broadcast();
  Stream<AudioState> get stateStream => _controller.stream;
  AudioState _state = AudioState.empty();
  AudioState get state => _state;

  late MyAudioHandler _audioHandler;

  Future<void> init() async {
    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: Utils().packageInfo.packageName,
        androidNotificationChannelName: 'Music Playback',
        androidNotificationIcon: 'mipmap/launcher_icon',
      ),
    );
    _listenToAudioHandler();
  }

  Future<void> scanAudioList() async {
    try {
      _state = _state.copyWith(error: '', isLoading: true, list: []);
      _controller.add(_state);

      final list = await AudioScanner().scan();
      list.sortDate();
      _state = _state.copyWith(isLoading: false, list: list);
      _controller.add(_state);
    } catch (e) {
      _state = _state.copyWith(error: e.toString(), isLoading: false);
      _controller.add(_state);
    }
  }

  void _listenToAudioHandler() {
    _audioHandler.player.playerStateStream.listen((event) {
      if (event.processingState == .completed) {
        _state = _state.copyWith(isPlaying: event.playing);
        _controller.add(_state);
      }
    });
    // _audioHandler.player.playerEventStream.listen((event) {
    //   print('playerEventStream: ${event}');
    // });

    // သီချင်းပြောင်းသွားတာကို နားထောင်မယ်
    _audioHandler.mediaItem.listen((item) {
      _state = _state.copyWith(currentSong: item);
      _controller.add(_state);
    });
  }

  void playTrack(String filePath, String title, String id) {
    final item = MediaItem(id: id, title: title);
    _audioHandler.playAudioFile(filePath, item);
    _audioHandler.play();
    _listenToAudioHandler();
  }

  Future<void> togglePlay() async {
    if (_state.isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }
}
