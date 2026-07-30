import 'package:than_player/core/models/video_file.dart';

sealed class VideoStateEvent {}

class VideoStateAddEvent extends VideoStateEvent {
  final VideoFile file;
  VideoStateAddEvent(this.file);
}

class VideoStateRemoveEvent extends VideoStateEvent {
  final VideoFile file;
  VideoStateRemoveEvent(this.file);
}

class VideoStateRenameEvent extends VideoStateEvent {
  final VideoFile file;
  VideoStateRenameEvent(this.file);
}
