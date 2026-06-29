import 'package:flutter/material.dart';
import 'package:than_player/core/models/video_file.dart';

class VideoContentScreen extends StatelessWidget {
  final VideoFile file;
  const VideoContentScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Placeholder());
  }
}
