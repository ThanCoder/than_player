// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/partials/sort_provider.dart';

class VideoState {
  final String error;
  final bool isLoading;
  final List<VideoFile> list;
  final SortItem sortItem;
  final Set<String> folderNames;
  const VideoState({
    required this.error,
    required this.isLoading,
    required this.list,
    required this.sortItem,
    required this.folderNames,
  });

  factory VideoState.empty() {
    return VideoState(
      error: '',
      isLoading: false,
      list: [],
      sortItem: SortItem.dateSortItem,
      folderNames: {},
    );
  }

  

  VideoState copyWith({
    String? error,
    bool? isLoading,
    List<VideoFile>? list,
    SortItem? sortItem,
    Set<String>? folderNames,
  }) {
    return VideoState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      sortItem: sortItem ?? this.sortItem,
      folderNames: folderNames ?? this.folderNames,
    );
  }
}
