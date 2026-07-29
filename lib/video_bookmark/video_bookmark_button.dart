import 'package:flutter/material.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/video_bookmark/video_bookmark_controller.dart';

class VideoBookmarkButton extends StatelessWidget {
  final VideoFile file;
  final double? iconSize;
  const VideoBookmarkButton({super.key, required this.file, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: VideoBookmarkController.instance.stream,
      builder: (context, asyncSnapshot) {
        final exists = VideoBookmarkController.instance.exists(file.id);

        return IconButton(
          mouseCursor: SystemMouseCursors.click,
          onPressed: () {
            if (exists) {
              VideoBookmarkController.instance.remove(file.id);
            } else {
              VideoBookmarkController.instance.add(file.id);
            }
          },
          icon: Icon(
            exists ? Icons.favorite : Icons.favorite_border,
            size: iconSize,
            color: exists ? Colors.blue : null,
          ),
        );
      },
    );
  }
}
