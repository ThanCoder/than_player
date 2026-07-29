import 'package:flutter/material.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/main/components/video_grid_item.dart';
import 'package:than_player/main/components/video_list_item.dart';
import 'package:than_player/main/home/video/video_func.dart';
import 'package:than_player/partials/list_style_provider.dart';
import 'package:than_player/video_config/video_config_services.dart';

class VideoListStyleProvider extends StatefulWidget {
  final List<VideoFile> list;
  const VideoListStyleProvider({super.key, required this.list});

  @override
  State<VideoListStyleProvider> createState() => _VideoListStyleProviderState();
}

class _VideoListStyleProviderState extends State<VideoListStyleProvider> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ListStyleProvider.valueNotifier,
      builder: (context, value, child) {
        if (value == .grid) {
          return gridStyleWidget();
        }
        return listStyleWidget();
      },
    );
  }

  Widget gridStyleWidget() {
    return SliverGrid.builder(
      itemCount: widget.list.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 150,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final file = widget.list[index];
        return FutureBuilder(
          future: VideoConfigServices.instance.getConfig(file.id, file.path),
          builder: (context, snapshot) {
            return VideoGridItem(
              file: file,
              config: snapshot.data,
              onMenuClicked: (file) => showVideoContextItemMenu(context, file),
              onClicked: onClickedItem,
            );
          },
        );
      },
    );
  }

  Widget listStyleWidget() {
    return SliverList.builder(
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        final file = widget.list[index];
        return FutureBuilder(
          future: VideoConfigServices.instance.getConfig(file.id, file.path),
          builder: (context, snapshot) {
            return VideoListItem(
              file: file,
              config: snapshot.data,
              onClicked: onClickedItem,
              onMenuClicked: (file) => showVideoContextItemMenu(context, file),
            );
          },
        );
      },
    );
  }

  void onClickedItem(VideoFile file) async {
    await goVideoContentScreen(context, file);
    if (!mounted) return;
    setState(() {});
  }
}
