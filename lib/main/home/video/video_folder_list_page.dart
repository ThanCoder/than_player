import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state_controller.dart';
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
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ListStyleProvider(),
          if (Platform.isLinux)
            IconButton(onPressed: refreshFiles, icon: Icon(Icons.refresh)),
        ],
      ),
      body: CustomScrollView(slivers: [styledList]),
    );
  }

  Widget get styledList {
    return StreamBuilder(
      stream: VideoStateController.instance.stateStream,
      builder: (context, asyncSnapshot) {
        final stateFiles = VideoStateController.instance.state.list;
        final stateFileMap = {for (var f in stateFiles) f.id: f};

        // widget.files ထဲက ID ရှိရင် State အသစ်ထဲက VideoFile ကို ယူမည်၊ မရှိရင် ဖယ်ထုတ်မည်
        final updatedFiles = widget.files
            .map((file) => stateFileMap[file.id])
            .whereType<VideoFile>() // null များကို ဖယ်ထုတ်ပေးပါသည်
            .toList();

        return VideoListStyleProvider(list: updatedFiles);
      },
    );
  }

  Future<void> refreshFiles() async {
    setState(() {});
  }
}
