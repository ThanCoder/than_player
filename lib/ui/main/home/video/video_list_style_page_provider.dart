import 'package:flutter/material.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/ui/video/video_grid_item.dart';
import 'package:than_player/ui/video/video_list_item.dart';
import 'package:than_player/ui/main/home/video/video_func.dart';
import 'package:than_player/ui/video/video_list_style_provider.dart';
import 'package:than_player/ui/video/video_config/video_config_services.dart';

class VideoListStylePageProvider extends StatefulWidget {
  final List<VideoFile> list;
  const VideoListStylePageProvider({super.key, required this.list});

  @override
  State<VideoListStylePageProvider> createState() =>
      _VideoListStylePageProviderState();
}

class _VideoListStylePageProviderState
    extends State<VideoListStylePageProvider> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: VideoListStyleProvider.valueNotifier,
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
