import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:t_widgets/t_widgets.dart' hide SortButton;
import 'package:than_pkg/than_pkg.dart' hide TPlatform;
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state.dart';
import 'package:than_player/core/state/video/video_state_controller.dart';
import 'package:than_player/core/utils/file_utils.dart';
import 'package:than_player/main/home/video/video_folder_list_style_provider.dart';
import 'package:than_player/main/home/video/video_func.dart';
import 'package:than_player/main/home/video/video_list_style_provider.dart';
import 'package:than_player/main/home/video/video_folder_type_provider.dart';
import 'package:than_player/partials/list_style_provider.dart';
import 'package:than_player/partials/sort_provider.dart';

class VideoHomePage extends StatefulWidget {
  final bool isCurrentPage;
  const VideoHomePage({super.key, required this.isCurrentPage});

  @override
  State<VideoHomePage> createState() => _VideoHomePageState();
}

class _VideoHomePageState extends State<VideoHomePage> {
  @override
  void initState() {
    super.initState();
    if (VideoStateController.instance.state.list.isNotEmpty) return;
    if (widget.isCurrentPage && !isCalled) {
      init();
    }
  }

  @override
  void didUpdateWidget(covariant VideoHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (VideoStateController.instance.state.list.isNotEmpty) return;
    if (widget.isCurrentPage && !isCalled) {
      init();
    }
  }

  bool isCalled = false;
  bool canVideoDrop = true;

  Future<void> init() async {
    try {
      if (!await ThanPkg.platform.isStoragePermissionGranted()) {
        await ThanPkg.platform.requestStoragePermission();
        return;
      }
      await VideoStateController.instance.scanList();
      isCalled = true;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DropTarget(
        enable: canVideoDrop,
        onDragDone: onFileDrop,
        child: bodyWidget,
      ),
    );
  }

  Widget get bodyWidget {
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
                SliverToBoxAdapter(child: headerWidget),
                // list
                videoListStyleWiget(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget get headerWidget {
    return Row(
      children: [
        VideoFolderTypeProvider(),

        Spacer(),
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
        ListStyleProvider(),
      ],
    );
  }

  Widget videoListStyleWiget(VideoState state) {
    return ValueListenableBuilder(
      valueListenable: VideoFolderTypeProvider.valueNotifier,
      builder: (context, value, child) {
        if (value == .allFolders) {
          return VideoFolderListStyleProvider(state: state);
        }
        return VideoListStyleProvider(list: state.list);
      },
    );
  }

  void onFileDrop(DropDoneDetails details) async {
    if (details.files.isEmpty) return;
    final f = details.files.first;
    final mm = lookupMimeType(f.path);
    if (mm == null) return;
    if (!mm.startsWith('video')) return;
    setState(() {
      canVideoDrop = false;
    });
    final vf = File(f.path);
    final file = VideoFile(
      name: f.name,
      path: f.path,
      dirname: vf.directory.onlyName,
      date: vf.modifiedDate,
      size: vf.size,
      id: await FileUtils.getFileId(f.path),
    );

    if (!mounted) return;

    await goVideoContentScreen(context, file);

    if (!mounted) return;
    setState(() {
      canVideoDrop = true;
    });
  }
}
