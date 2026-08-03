import 'package:flutter/material.dart';
import 'package:than_player/ui/audio/audio_bookmark/audio_bookmark_controller.dart';
import 'package:than_player/core/models/audio_file.dart';

class AudioBookmarkButton extends StatelessWidget {
  final AudioFile file;
  final double? iconSize;
  const AudioBookmarkButton({super.key, required this.file, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AudioBookmarkController.instance.stream,
      builder: (context, asyncSnapshot) {
        final exists = AudioBookmarkController.instance.exists(file.id);

        return IconButton(
          mouseCursor: SystemMouseCursors.click,
          onPressed: () {
            if (exists) {
              AudioBookmarkController.instance.remove(file.id);
            } else {
              AudioBookmarkController.instance.add(file.id);
            }
          },
          icon: Icon(
            exists ? Icons.favorite : Icons.favorite_border,
            size: iconSize,
          ),
        );
      },
    );
  }
}
