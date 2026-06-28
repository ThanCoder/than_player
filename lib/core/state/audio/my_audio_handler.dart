import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

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
    await _startFade(targetVolume: 1.0, duration: Duration(milliseconds: 1000));
  }

  @override
  Future<void> pause() async {
    await _startFade(targetVolume: 0.0, duration: Duration(milliseconds: 1000));
    await _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> stop() async {
    await _startFade(targetVolume: 0.0, duration: Duration(milliseconds: 1000));
    // ၁။ Player ကို အရင် ရပ်လိုက်ပါ
    await _player.stop();

    // ၂။ audio_service ကို ရပ်လိုက်ပြီဖြစ်ကြောင်း အရင် အသိပေးပါ (System ကို အရင်ရှင်းတာ)
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );

    // ၃။ super.stop() ကို အရင်ခေါ်ပြီး background service ကို အရင်သတ်ပါ
    await super.stop();

    // ၄။ နောက်ဆုံးမှ media_kit ရဲ့ native references တွေကို သတ်ပစ်ပါ
    await _player.dispose();
  }

  // 💡 ပြင်ဆင်ချက် ၃: Parameter ထဲက PlaybackEvent ကို ဖြုတ်လိုက်ပြီး _player ရဲ့ လက်ရှိ state အစစ်ကို တိုက်ရိုက်ယူခိုင်းလိုက်ပါတယ်
  PlaybackState _transformEvent() {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
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

  //***********Fade Effect************ */
  // 💡 Fade ကို ထိန်းချုပ်ဖို့ Timer တစ်ခု သတ်မှတ်မယ်
  Timer? _fadeTimer;

  // ... (Constructor တွေ ရှိပြီးသားအတိုင်း ထားပါ)

  // 💡 ဒါက အသံကို တုန်မသွားစေဘဲ ပုရွက်ဆိတ်လျှောက်သလို ညင်သာအောင် အသံညှိပေးမယ့် Master Function ပါ
  Future<void> _startFade({
    required double targetVolume,
    required Duration duration,
  }) async {
    _fadeTimer?.cancel(); // လည်နေတဲ့ အဟောင်းရှိရင် အရင်သတ်မယ်

    final int steps = 20;
    final int interval = duration.inMilliseconds ~/ steps;
    final double startVolume = _player.volume;
    final double volumeDiff = targetVolume - startVolume;
    int currentStep = 0;

    _fadeTimer = Timer.periodic(Duration(milliseconds: interval), (
      timer,
    ) async {
      currentStep++;
      final double newVolume =
          startVolume + (volumeDiff * (currentStep / steps));

      // Target ရောက်ရင် ရပ်မယ်
      if (currentStep >= steps) {
        await _player.setVolume(targetVolume);
        timer.cancel();
      } else {
        await _player.setVolume(newVolume);
      }
    });
    await Future.delayed(duration);
  }
}
