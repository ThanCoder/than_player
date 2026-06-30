import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/core/state/audio/my_audio_handler.dart';
import 'package:than_player/core/utils/audio_scanner.dart';
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
      //**************Sort****************** */
      SortItem sortItem = sortList[1];
      final recentSortId = CFBStoreBase.getInstance.getInt(
        'audio-file-sort-id',
        sortItem.id,
      );
      final recentSortTrue = CFBStoreBase.getInstance.getBool(
        'audio-file-sort-true',
      );
      if (recentSortId != sortItem.id) {
        final index = sortList.indexWhere((e) => e.id == recentSortId);
        if (index != -1) {
          sortItem = sortList[index].copyWith(isTrue: recentSortTrue);
        }
      }
      _state = _state.copyWith(
        error: '',
        isLoading: true,
        list: [],
        sortItem: sortItem,
      );
      _controller.add(_state);

      final list = await AudioScanner().scan();
      _state = _state.copyWith(isLoading: false, list: list);
      sort();
      _controller.add(_state);
    } catch (e) {
      _state = _state.copyWith(error: e.toString(), isLoading: false);
      _controller.add(_state);
    }
  }

  void sort() {
    if (_state.sortItem.id == SortItem.nameSortItem.id) {
      _state.list.sortName(isA2Z: _state.sortItem.isTrue);
    } else if (_state.sortItem.id == SortItem.dateSortItem.id) {
      _state.list.sortDate(isNewest: _state.sortItem.isTrue);
    } else if (_state.sortItem.id == SortItem.sizeSortItem.id) {
      _state.list.sortSize(smToBig: _state.sortItem.isTrue);
    }
  }

  void setSort(SortItem item) {
    CFBStoreBase.getInstance.put('audio-file-sort-id', item.id);
    CFBStoreBase.getInstance.put('audio-file-sort-true', item.isTrue);
    CFBStoreBase.getInstance.writeAll();

    _state = _state.copyWith(sortItem: item);
    sort();
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
    debugPrint('file.cachCoverPath: ${file.cachCoverPath}');
    final item = MediaItem(
      id: file.name,
      title: file.meta.title ?? file.name,
      duration: file.meta.duration,
      artUri: Uri.file(file.cachCoverPath),
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

  void prev() async {
    final current = state.currentSong;
    if (current == null) return;
    final index = _state.list.indexWhere((e) => e.name == current.id);
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
    final index = _state.list.indexWhere((e) => e.name == current.id);
    if (index > state.list.length) {
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
    final index = _state.list.indexWhere((e) => e.name == id);
    if (index != -1) {
      return state.list[index];
    }
    return null;
  }

  AudioFile? get currentAudioFile {
    if (state.currentSong == null) return null;
    final index = _state.list.indexWhere(
      (e) => e.name == state.currentSong!.id,
    );
    if (index != -1) {
      return state.list[index];
    }
    return null;
  }

  Future<String> get currentCoverPath async {
    if (state.currentSong == null) return '';
    final file = getAudioFileById(state.currentSong!.id);
    if (file == null) return '';
    return await file.meta.readImageCache(file.cacheName);
  }
}
