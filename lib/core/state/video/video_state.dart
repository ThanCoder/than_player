// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/video_file.dart';

class VideoState {
  final String error;
  final bool isLoading;
  final List<VideoFile> list;
  final int sortId;
  final bool isAsc;
  const VideoState({
    required this.error,
    required this.isLoading,
    required this.list,
    required this.sortId,
    required this.isAsc,
  });

  factory VideoState.empty() {
    return VideoState(
      error: '',
      isLoading: false,
      list: [],
      sortId: TSort.getDateId,
      isAsc: true,
    );
  }

  VideoState copyWith({
    String? error,
    bool? isLoading,
    List<VideoFile>? list,
    int? sortId,
    bool? isAsc,
  }) {
    return VideoState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      list: list ?? this.list,
      sortId: sortId ?? this.sortId,
      isAsc: isAsc ?? this.isAsc,
    );
  }
}
