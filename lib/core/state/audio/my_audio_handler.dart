import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {

    // Player ရဲ့ State ပြောင်းလဲမှုတွေကို Notification ဘက်ဆီ လှမ်းတွန်းပေးဖို့ နားထောင်ထားမယ်
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
   
  }

  AudioPlayer get player => _player;

  Future<void> playAudioFile(String filePath, MediaItem item) async {
    mediaItem.add(item);
    await _player.setAudioSource(AudioSource.file(filePath));
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
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> stop() async {
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

  // just_audio state ကနေ audio_service state ပြောင်းပေးတဲ့ Helper function
  PlaybackState _transformEvent(PlaybackEvent event) {
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
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
