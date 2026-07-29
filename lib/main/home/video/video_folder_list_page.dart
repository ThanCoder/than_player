import 'package:flutter/material.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/main/home/video/video_list_style_provider.dart';
import 'package:than_player/partials/list_style_provider.dart';

class VideoFolderListPage extends StatefulWidget {
  final String title;
  final List<VideoFile> files;
  const VideoFolderListPage({
    super.key,
    required this.title,
    required this.files,
  });

  @override
  State<VideoFolderListPage> createState() => _VideoFolderListPageState();
}

class _VideoFolderListPageState extends State<VideoFolderListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [ListStyleProvider()]),
      body: CustomScrollView(slivers: [styledList]),
    );
  }

  Widget get styledList {
    return VideoListStyleProvider(list: widget.files);
  }
}
