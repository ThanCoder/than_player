import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_player/core/models/video_file.dart';

class VideoListItem extends StatelessWidget {
  final VideoFile file;
  final void Function(VideoFile file)? onClicked;
  final void Function(VideoFile file)? onMenuClicked;
  const VideoListItem({
    super.key,
    required this.file,
    this.onClicked,
    this.onMenuClicked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onClicked?.call(file),
      onLongPress: () => onMenuClicked?.call(file),
      onSecondaryTap: () => onMenuClicked?.call(file),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 4,
          children: [
            SizedBox(width: 100, height: 100, child: thumbnail),
            Expanded(
              child: Column(
                spacing: 3,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.name),
                  Text(IntSizeLabelExtension(file.size).toFileSizeLabel()),
                  Text(file.date.formatDateTimeAgo()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get thumbnail {
    final thumbnailFile = File(file.cachCoverPath);
    // print(thumbnailFile);

    if (thumbnailFile.existsSync()) return TImage(source: thumbnailFile.path);
    return FutureBuilder(
      // future: VideoUtils.genVideoThumbnail(file.path, thumbnailFile),
      future: ThanPkg.platform.genVideoThumbnail(
        pathList: [SrcDistType(src: file.path, dist: thumbnailFile.path)],
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return TLoader();
        }
        return TImage(source: thumbnailFile.path);
      },
    );
  }
}
