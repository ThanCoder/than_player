import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state_controller.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/main/components/video_list_item.dart';
import 'package:than_player/main/home/video/video_content_screen.dart';
import 'package:than_player/partials/sort_provider.dart';

class VideoHomePage extends StatefulWidget {
  const VideoHomePage({super.key});

  @override
  State<VideoHomePage> createState() => _VideoHomePageState();
}

class _VideoHomePageState extends State<VideoHomePage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    try {
      if (!await ThanPkg.platform.isStoragePermissionGranted()) {
        await ThanPkg.platform.requestStoragePermission();
        return;
      }
      await VideoStateController.instance.scanList();
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !TPlatform.isDesktop
          ? null
          : AppBar(
              title: Text('Audio Player'),
              actions: [
                if (TPlatform.isDesktop)
                  IconButton(onPressed: init, icon: Icon(Icons.refresh)),
                StreamBuilder(
                  stream: VideoStateController().stateStream,
                  builder: (context, asyncSnapshot) {
                    return SortButton(
                      value: VideoStateController().state.sortItem,
                      list: VideoStateController().sortList,
                      onApply: (item) {
                        VideoStateController().setSort(item);
                      },
                    );
                  },
                ),
              ],
            ),
      body: listWidget,
    );
  }

  Widget get listWidget {
    return StreamBuilder(
      stream: VideoStateController.instance.stateStream,
      initialData: VideoStateController.instance.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        if (state.isLoading) {
          return Center(child: TLoaderRandom());
        }
        if (state.list.isEmpty) {
          return Center(
            child: RefreshButton(text: Text('Refersh'), onClicked: init),
          );
        }
        return RefreshIndicator.adaptive(
          onRefresh: init,
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // SliverToBoxAdapter(child: headerWidget(state)),
                // list
                SliverList.builder(
                  itemCount: state.list.length,
                  itemBuilder: (context, index) => listItem(state.list[index]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget listItem(VideoFile file) {
    return VideoListItem(
      file: file,
      onClicked: (file) async {
        await context.push(
          builder: (mainContext) => VideoContentScreen(file: file),
        );
        if (!mounted) return;
        setState(() {});
      },
    );
  }
}
