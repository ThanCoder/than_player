// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/partials/sort_provider.dart';

class AllAudioState {
  final List<AudioFile> list;
  final bool isLoading;
  final SortItem sortItem;
  final String error;
  const AllAudioState({
    required this.list,
    required this.isLoading,
    required this.sortItem,
    required this.error,
  });
  factory AllAudioState.empty() {
    return AllAudioState(
      list: [],
      isLoading: false,
      sortItem: .dateSortItem,
      error: '',
    );
  }

  AllAudioState copyWith({
    List<AudioFile>? list,
    bool? isLoading,
    SortItem? sortItem,
    String? error,
  }) {
    return AllAudioState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      sortItem: sortItem ?? this.sortItem,
      error: error ?? this.error,
    );
  }
}
