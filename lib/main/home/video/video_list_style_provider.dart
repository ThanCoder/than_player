import 'package:flutter/material.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/main/components/video_grid_item.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/main/components/video_list_item.dart';
import 'package:than_player/main/home/video/video_content_screen.dart';
import 'package:than_player/main/home/video/video_context_menu_func.dart';
import 'package:than_player/partials/list_style_provider.dart';

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
        maxCrossAxisExtent: 180,
        mainAxisExtent: 150,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final file = widget.list[index];
        return VideoGridItem(
          file: file,
          onMenuClicked: (file) => showVideoContextItemMenu(context, file),
          onClicked: onClickedItem,
        );
      },
    );
  }

  Widget listStyleWidget() {
    return SliverList.builder(
      itemCount: widget.list.length,
      itemBuilder: (context, index) {
        final file = widget.list[index];
        return VideoListItem(
          file: file,
          onClicked: onClickedItem,
          onMenuClicked: (file) => showVideoContextItemMenu(context, file),
        );
      },
    );
  }

  void onClickedItem(VideoFile file) async {
    await context.push(
      builder: (mainContext) => VideoContentScreen(file: file),
    );
    if (!mounted) return;
    setState(() {});
  }
}
