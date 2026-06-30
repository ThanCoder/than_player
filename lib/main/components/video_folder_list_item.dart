import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_player/core/models/video_file.dart';

class VideoFolderListItem extends StatelessWidget {
  final String folderName;
  final List<VideoFile> files;
  final void Function(String folderName, List<VideoFile> files)? onClicked;
  final void Function(String folderName, List<VideoFile> files)? onMenuClicked;
  const VideoFolderListItem({
    super.key,
    required this.folderName,
    required this.files,
    this.onClicked,
    this.onMenuClicked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onClicked?.call(folderName, files),
      onLongPress: () => onMenuClicked?.call(folderName, files),
      onSecondaryTap: () => onMenuClicked?.call(folderName, files),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 4,
          children: [
            SizedBox(width: 100, height: 100, child: thumbnail),
            Expanded(
              child: Row(
                children: [
                  Column(
                    spacing: 3,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(folderName),
                      Text('${files.length} Videos'),
                      getAllSizeWidget,
                      // Text(IntSizeLabelExtension(file.size).toFileSizeLabel()),
                      // Text(file.date.formatDateTimeAgo()),
                    ],
                  ),
                  Spacer(),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get getAllSizeWidget {
    int size = 0;
    for (var file in files) {
      size += file.size;
    }
    if (size > 0) {
      return Text(size.fileSizeLabel());
    }
    return SizedBox.shrink();
  }

  Widget get thumbnail {
    return Icon(Icons.folder, size: 100);
  }
}
