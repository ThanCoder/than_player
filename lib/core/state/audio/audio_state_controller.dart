import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:than_player/audio_bookmark/audio_bookmark_controller.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/core/state/audio/my_audio_handler.dart';
import 'package:than_player/core/utils/utils.dart';
import 'package:than_player/partials/sort_provider.dart';

class AudioStateController {
  static AudioStateController instance = AudioStateController._();
  AudioStateController._();
  factory AudioStateController() => instance;

  final _controller = StreamController<AudioState>.broadcast();
  Stream<AudioState> get stateStream => _controller.stream;
  AudioState _state = AudioState.empty();
  AudioState get state => _state;
  final List<SortItem> sortList = [
    SortItem.nameSortItem,
    SortItem.dateSortItem,
    SortItem.sizeSortItem,
  ];

  late MyAudioHandler _audioHandler;
  bool isInitialized = false;

  Future<void> init() async {
    if (isInitialized) return;
    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: Utils().packageInfo.packageName,
        androidNotificationChannelName: 'Music Playback',
        androidNotificationIcon: 'mipmap/launcher_icon',
      ),
    );
    isInitialized = true;

    _listenToAudioHandler();
  }

  void setAudioList(List<AudioFile> files) {
    _state = _state.copyWith(list: files);
    _controller.add(_state);
  }

  Stream<PlaybackEvent> get playbackEventStream =>
      _audioHandler.player.playbackEventStream;

  void _listenToAudioHandler() {
    _audioHandler.playbackState.listen((value) {
      // song end

      if (value.playing != state.isPlaying) {
        _state = _state.copyWith(isPlaying: value.playing);
        _controller.add(_state);
      }
      bool isNextSongTriggered = false; // အပေါ်မှာ Flag တစ်ခု ကြေညာထားမယ်

      // listen ထဲမှာ ဒီလို စစ်ပါ
      if (value.processingState == AudioProcessingState.completed) {
        if (!isNextSongTriggered) {
          _state = _state.copyWith(isPlaying: false);
          _controller.add(_state);
          isNextSongTriggered = true; // တစ်ခါဝင်ပြီးရင် ပိတ်လိုက်မယ်
          next(); //go next song
        }
      } else {
        isNextSongTriggered = false;
      }
    });

    // သီချင်းပြောင်းသွားတာကို နားထောင်မယ်
    _audioHandler.mediaItem.listen((item) {
      _state = _state.copyWith(currentSong: item);
      _controller.add(_state);
    });
  }

  Future<void> playTrack(AudioFile file) async {
    var title = file.meta.title;
    if (title.isEmpty) {
      title = file.name;
    }
    final item = MediaItem(
      id: file.id,
      title: title,
      duration: file.meta.duration,
      artUri: Uri.file(file.cacheCoverPath),
    );
    _state = _state.copyWith(showFloatingAudioWidget: true);
    await _audioHandler.playAudioFile(file.path, item);
  }

  void seek(Duration duration) {
    _audioHandler.seek(duration);
  }

  Future<void> togglePlay() async {
    if (_state.isPlaying) {
      await _audioHandler.pause();
    } else {
      await _audioHandler.play();
    }
  }

  Future<void> pause() async {
    await _audioHandler.pause();
  }

  bool existsByIndex(int index) {
    return index >= 0 && index < _state.list.length;
  }

  bool get currentSongBookmarked {
    if (state.currentSong == null) return false;
    return AudioBookmarkController.instance.exists(state.currentSong!.id);
  }

  int get currentSongIndex {
    if (state.currentSong == null) return -1;
    return state.list.indexWhere((e) => e.id == state.currentSong!.id);
  }

  void prev() async {
    final current = state.currentSong;
    if (current == null) return;
    final index = _state.list.indexWhere((e) => e.id == current.id);
    if (index == -1) {
      return;
    }
    if (index == 0) return;
    final file = state.list[index - 1];
    playTrack(file);
  }

  void next() async {
    final current = state.currentSong;
    if (current == null) return;
    final index = _state.list.indexWhere((e) => e.id == current.id);
    if (index + 1 == state.list.length) {
      return;
    }
    final file = state.list[index + 1];
    playTrack(file);
  }

  Future<void> disposePlayerServices() async {
    await _audioHandler.stop();
    await _audioHandler.player.dispose();
  }

  void refershState() {
    _controller.add(_state);
  }

  void setVisiableFloatingAudioWidget(bool isVisiable) {
    _state = _state.copyWith(showFloatingAudioWidget: isVisiable);
    _controller.add(_state);
  }

  AudioFile? getAudioFileById(String id) {
    final index = _state.list.indexWhere((e) => e.id == id);
    if (index != -1) {
      return state.list[index];
    }
    return null;
  }

  bool isCurrentSong(String id) {
    if (state.currentSong == null) return false;
    if (state.currentSong!.id == id) return true;
    return false;
  }

  AudioFile? get currentAudioFile {
    if (state.currentSong == null) return null;
    final index = _state.list.indexWhere((e) => e.id == state.currentSong!.id);
    if (index != -1) {
      return state.list[index];
    }
    return null;
  }

  String? get currentCoverCachePath {
    if (state.currentSong == null) return '';
    final file = getAudioFileById(state.currentSong!.id);
    if (file == null) return null;
    return file.cacheCoverPath;
  }

  String get currentCoverPath {
    if (state.currentSong == null) return '';
    final file = getAudioFileById(state.currentSong!.id);
    if (file == null) return '';
    return file.cacheCoverPath;
  }
}
