import 'package:flutter/material.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/ui/video/video_folder_list_item.dart';
import 'package:than_player/ui/main/home/video/video_folder_result_page.dart';

class VideoFolderListStyleProvider extends StatelessWidget {
  final VideoState state;
  const VideoFolderListStyleProvider({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final folders = <String, List<VideoFile>>{};
    for (var file in state.list) {
      folders.putIfAbsent(file.dirname, () => []).add(file);
    }
    final folderNames = folders.keys.toList();
    return SliverList.builder(
      itemCount: folderNames.length,
      itemBuilder: (context, index) {
        // final folder = folders[index];
        final name = folderNames[index];
        return VideoFolderListItem(
          folderName: name,
          files: folders[name] ?? [],
          onClicked: (folderName, files) {
            context.push(
              builder: (mainContext) =>
                  VideoFolderResultPage(title: name, files: files),
            );
          },
        );
      },
    );
  }
}
