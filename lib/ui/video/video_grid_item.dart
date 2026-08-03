import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/utils/platform_utils.dart';
import 'package:than_player/ui/video/video_bookmark/video_bookmark_button.dart';
import 'package:than_player/ui/video/video_config/video_config.dart';

class VideoGridItem extends StatelessWidget {
  final VideoFile file;
  final VideoConfig? config;
  final void Function(VideoFile file)? onClicked;
  final void Function(VideoFile file)? onMenuClicked;
  const VideoGridItem({
    super.key,
    required this.file,
    this.config,
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
                    if (config != null && config!.duration != .zero)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: durationWidget(config!.duration),
                      ),
                    if (config != null &&
                        config!.duration != .zero &&
                        config!.current != .zero)
                      Positioned(
                        left: 0,
                        bottom: 0,
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

  Widget durationWidget(Duration dur) {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .5),
        borderRadius: .circular(2),
      ),
      child: Text(
        dur.toRemainingLabel(),
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget positionProgressWiget(VideoConfig config) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.black),
          child: Text(
            '${config.current.formatTimeLable()}/${config.duration.formatTimeLable()}',
            style: TextStyle(fontSize: 10, color: Colors.blue),
          ),
        ),
        LinearProgressIndicator(
          value: config.current.inMilliseconds / config.duration.inMilliseconds,
        ),
      ],
    );
  }

  Widget get thumbnailWidget {
    final thumbnailFile = File(file.cachCoverPath);
    // print(thumbnailFile);

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
