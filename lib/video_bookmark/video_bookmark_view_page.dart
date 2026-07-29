import 'package:flutter/material.dart';
import 'package:than_player/core/state/video/video_state_controller.dart';
import 'package:than_player/main/home/video/video_list_style_provider.dart';
import 'package:than_player/partials/list_style_provider.dart';
import 'package:than_player/video_bookmark/video_bookmark_controller.dart';

class VideoBookmarkViewPage extends StatefulWidget {
  const VideoBookmarkViewPage({super.key});

  @override
  State<VideoBookmarkViewPage> createState() => _VideoBookmarkViewPageState();
}

class _VideoBookmarkViewPageState extends State<VideoBookmarkViewPage> {
  @override
  void initState() {
    super.initState();
    if (VideoStateController.instance.state.list.isEmpty) {
      VideoStateController.instance.scanList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [ListStyleProvider()]),
      body: StreamBuilder(
        stream: VideoStateController().stateStream,
        builder: (context, asyncSnapshot) {
          return StreamBuilder(
            stream: VideoBookmarkController.instance.stream,
            builder: (context, asyncSnapshot) {
              final list = VideoBookmarkController.instance.getVideoFiles();
              return CustomScrollView(
                slivers: [VideoListStyleProvider(list: list)],
              );
            },
          );
        },
      ),
    );
  }
}
