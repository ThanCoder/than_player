import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_player/core/models/video_file.dart';

class VideoGridItem extends StatelessWidget {
  final VideoFile file;
  final void Function(VideoFile file)? onClicked;
  final void Function(VideoFile file)? onMenuClicked;
  const VideoGridItem({
    super.key,
    required this.file,
    this.onClicked,
    this.onMenuClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => onClicked?.call(file),
        onLongPress: () => onMenuClicked?.call(file),
        onSecondaryTap: () => onMenuClicked?.call(file),
        child: Column(
          spacing: 4,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(child: thumbnailWidget),
                    Positioned(bottom: 0, right: 0, child: durationWidget),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    file.name,
                    style: TextStyle(fontSize: 10, fontWeight: .bold),
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => onMenuClicked?.call(file),
                  child: Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get durationWidget {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .5),
        borderRadius: .circular(2),
      ),
      child: Text(
        file.duration.toRemainingLabel(),
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget get thumbnailWidget {
    final thumbnailFile = File(file.cachCoverPath);
    // print(thumbnailFile);

    if (thumbnailFile.existsSync()) return TImage(source: thumbnailFile.path);
    return FutureBuilder(
      // future: VideoUtils.genVideoThumbnail(file.path, thumbnailFile),
      future: ThanPkg.platform.genVideoThumbnail(
        pathList: [SrcDistType(src: file.path, dist: thumbnailFile.path)],
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return TLoader();
        }
        return TImage(source: thumbnailFile.path);
      },
    );
  }
}
