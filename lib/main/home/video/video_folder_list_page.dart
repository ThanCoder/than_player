import 'package:flutter/material.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/main/components/video_list_item.dart';
import 'package:than_player/main/home/video/video_content_screen.dart';

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
      appBar: AppBar(title: Text(widget.title)),
      body: CustomScrollView(slivers: [styledList]),
    );
  }

  Widget get styledList {
    return SliverList.builder(
      itemCount: widget.files.length,
      itemBuilder: (context, index) => listItem(widget.files[index]),
    );
  }

  Widget listItem(VideoFile file) {
    return VideoListItem(
      file: file,
      onClicked: (file) async {
        await context.push(
          builder: (mainContext) => VideoContentScreen(file: file),
        );
        if (!mounted) return;
        setState(() {});
      },
    );
  }
}
