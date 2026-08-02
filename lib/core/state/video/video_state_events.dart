import 'package:than_player/core/models/video_file.dart';

sealed class VideoStateEvent {}

class VideoStateAddEvent extends VideoStateEvent {
  final VideoFile file;
  final String? eventKey;
  VideoStateAddEvent(this.file, {this.eventKey});
}

class VideoStateRemoveEvent extends VideoStateEvent {
  final VideoFile file;
  final String? eventKey;
  VideoStateRemoveEvent(this.file, {this.eventKey});
}

class VideoStateRenameEvent extends VideoStateEvent {
  final VideoFile file;
  final String? eventKey;
  VideoStateRenameEvent(this.file, {this.eventKey});
}
