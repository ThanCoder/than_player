// ignore_for_file: public_member_api_docs, sort_constructors_first
class VideoConfig {
  final Duration duration;
  final Duration current;
  const VideoConfig({required this.duration, required this.current});

  @override
  String toString() => 'VideoConfig(duration: $duration, current: $current)';
}
