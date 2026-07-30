import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:than_player/audio_bookmark/audio_bookmark_controller.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer(handleAudioSessionActivation: false);

  MyAudioHandler() {
    // 💡 ပြင်ဆင်ချက် ၁: Event Stream ပြောင်းလဲမှုကို နားထောင်ပြီး state အသစ်သွင်းမယ်
    _player.playbackEventStream.listen((event) {
      playbackState.add(_transformEvent());
    });

    // 💡 ပြင်ဆင်ချက် ၂: Play/Pause စတဲ့ State ပြောင်းလဲမှုတွေကိုပါ သီးသန့်နားထောင်ပြီး Notification ကို အတင်း Update လုပ်ခိုင်းမယ်
    _player.playerStateStream.listen((state) {
      playbackState.add(_transformEvent());
    });
  }

  AudioPlayer get player => _player;

  Future<void> playAudioFile(String filePath, MediaItem item) async {
    try {
      mediaItem.add(item);
      await _player.setAudioSource(AudioSource.file(filePath));
      await play();
    } catch (e) {
      debugPrint('[MyAudioHandler:playAudioFile]: $e');
    }
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> skipToPrevious() async {
    AudioStateController.instance.prev();
  }

  @override
  Future<void> skipToNext() async {
    AudioStateController.instance.next();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) {
    final current = AudioStateController.instance.currentAudioFile;
    if (name == 'favorite' && current != null) {
      AudioBookmarkController.instance.remove(current.id);
    }
    if (name == 'favorite_outline' && current != null) {
      AudioBookmarkController.instance.add(current.id);
    }

    return super.customAction(name, extras);
  }

  @override
  Future<void> stop() async {
    await _player.pause();
    await seek(Duration(seconds: 0));

    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );

    // ၃။ super.stop() ကို အရင်ခေါ်ပြီး background service ကို အရင်သတ်ပါ
    await super.stop();
  }

  PlaybackState _transformEvent() {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
        if (AudioStateController.instance.currentSongBookmarked)
          MediaControl.custom(
            androidIcon: "drawable/favorite",
            label: 'Favorite',
            name: 'favorite',
          )
        else
          MediaControl.custom(
            androidIcon: "drawable/favorite_outline",
            label: 'UnFavorite',
            name: 'favorite_outline',
          ),
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState:
          const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState] ??
          AudioProcessingState.idle, // ! အစား ?? သုံးထားလို့ ပိုစိတ်ချရပါတယ်
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
    );
  }
}
