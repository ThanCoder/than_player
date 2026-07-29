// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audio_service/audio_service.dart';

import 'package:than_player/core/models/audio_file.dart';

class AudioState {
  final String error;
  final bool isLoading;
  final List<AudioFile> list;
  final bool isPlaying;
  final bool showFloatingAudioWidget;
  final MediaItem? currentSong;
  const AudioState({
    required this.error,
    required this.isLoading,
    required this.list,
    required this.isPlaying,
    required this.showFloatingAudioWidget,
    this.currentSong,
  });
  factory AudioState.empty() {
    return AudioState(
      error: '',
      isLoading: false,
      list: [],
      isPlaying: false,
      showFloatingAudioWidget: false,
    );
  }

  AudioState copyWith({
    String? error,
    bool? isLoading,
    List<AudioFile>? list,
    bool? isPlaying,
    bool? showFloatingAudioWidget,
    MediaItem? currentSong,
  }) {
    return AudioState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      isPlaying: isPlaying ?? this.isPlaying,
      showFloatingAudioWidget:
          showFloatingAudioWidget ?? this.showFloatingAudioWidget,
      currentSong: currentSong ?? this.currentSong,
    );
  }
}
