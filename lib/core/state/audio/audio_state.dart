// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audio_service/audio_service.dart';

import 'package:than_player/core/models/audio_file.dart';

class AudioState {
  final String error;
  final bool isLoading;
  final List<AudioFile> list;
  final int sortId;
  final bool isAsc;
  final bool isPlaying;
  final MediaItem? currentSong;
  const AudioState({
    required this.error,
    required this.isLoading,
    required this.list,
    required this.sortId,
    required this.isAsc,
    this.currentSong, required this.isPlaying,
  });
  factory AudioState.empty() {
    return AudioState(
      error: '',
      isLoading: false,
      list: [],
      sortId: 0,
      isAsc: false,
      isPlaying: false
    );
  }

  

  AudioState copyWith({
    String? error,
    bool? isLoading,
    List<AudioFile>? list,
    int? sortId,
    bool? isAsc,
    bool? isPlaying,
    MediaItem? currentSong,
  }) {
    return AudioState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      sortId: sortId ?? this.sortId,
      isAsc: isAsc ?? this.isAsc,
      isPlaying: isPlaying ?? this.isPlaying,
      currentSong: currentSong ?? this.currentSong,
    );
  }
}
