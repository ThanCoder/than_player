// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/partials/sort_provider.dart';

class VideoState {
  final String error;
  final bool isLoading;
  final List<VideoFile> list;
  final SortItem sortItem;
  const VideoState({
    required this.error,
    required this.isLoading,
    required this.list,
    required this.sortItem,
  });

  factory VideoState.empty() {
    return VideoState(
      error: '',
      isLoading: false,
      list: [],
      sortItem: SortItem.dateSortItem,
    );
  }

  VideoState copyWith({
    String? error,
    bool? isLoading,
    List<VideoFile>? list,
    SortItem? sortItem,
  }) {
    return VideoState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      sortItem: sortItem ?? this.sortItem,
    );
  }
}
