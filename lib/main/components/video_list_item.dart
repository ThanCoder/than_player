import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/utils/platform_utils.dart';
import 'package:than_player/video_bookmark/video_bookmark_button.dart';
import 'package:than_player/video_config/video_config.dart';

class VideoListItem extends StatelessWidget {
  final VideoFile file;
  final VideoConfig? config;
  final void Function(VideoFile file)? onClicked;
  final void Function(VideoFile file)? onMenuClicked;
  const VideoListItem({
    super.key,
    required this.file,
    this.onClicked,
    this.onMenuClicked,
    required this.config,
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
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(child: thumbnail),
                  Positioned(
                    bottom: config == null ? 0 : 10,
                    right: 0,
                    child: durationWidget,
                  ),
                  if (config != null &&
                      config!.duration != .zero &&
                      config!.current != .zero)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: positionProgressWiget(config!),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: VideoBookmarkButton(file: file),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                spacing: 3,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 2,
                    style: TextStyle(fontSize: 10, fontWeight: .bold),
                  ),
                  Text(IntSizeLabelExtension(file.size).toFileSizeLabel()),
                  Text(file.date.formatDateTimeAgo()),
                  if (config != null && config!.current != .zero)
                    Text(
                      '${config!.current.formatTimeLable()}/${config!.duration.formatTimeLable()}',
                      style: TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget positionProgressWiget(VideoConfig config) {
    return LinearProgressIndicator(
      value: config.current.inMilliseconds / config.duration.inMilliseconds,
    );
  }

  Widget get durationWidget {
    if ((config == null || config!.duration == .zero)) {
      return SizedBox.shrink();
    }
    var duration = config!.duration;

    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .5),
        borderRadius: .circular(2),
      ),
      child: Text(
        duration.toRemainingLabel(),
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget get thumbnail {
    final thumbnailFile = File(file.cachCoverPath);

    if (thumbnailFile.existsSync()) return TImage(source: thumbnailFile.path);
    return FutureBuilder(
      future: PlatformUtils.genVideoThumbnail(
        file.path,
        thumbnailFile.path,
        width: 400,
        height: 400,
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
