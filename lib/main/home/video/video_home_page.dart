import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart' hide TPlatform;
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state.dart';
import 'package:than_player/core/state/video/video_state_controller.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/main/components/video_folder_list_item.dart';
import 'package:than_player/main/components/video_list_item.dart';
import 'package:than_player/main/home/video/types.dart';
import 'package:than_player/main/home/video/video_content_screen.dart';
import 'package:than_player/main/home/video/video_folder_list_page.dart';
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
  }

  @override
  void didUpdateWidget(covariant VideoHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPage && !isCalled) {
      init();
    }
  }

  bool isCalled = false;
  VideoFolderType folderType = .allFolders;

  Future<void> init() async {
    try {
      if (!await ThanPkg.platform.isStoragePermissionGranted()) {
        await ThanPkg.platform.requestStoragePermission();
        return;
      }
      await VideoStateController.instance.scanList();
      isCalled = true;
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Video Player'),
      //   actions: [

      //   ],
      // ),
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
                SliverToBoxAdapter(child: headerWidget),
                // list
                styledList(state),
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
        TextButton(
          onPressed: () async {
            await showMenu(
              context: context,
              positionBuilder: (context, constraints) => RelativeRect.fill,
              items: [
                PopupMenuItem(
                  child: CheckboxListTile.adaptive(
                    title: Text("All Videos"),
                    value: folderType == .allVideo,
                    onChanged: (value) {
                      setState(() {
                        folderType = .allVideo;
                        context.pop();
                      });
                    },
                  ),
                ),
                PopupMenuItem(
                  enabled: true,
                  child: CheckboxListTile.adaptive(
                    title: Text("All Folders"),
                    value: folderType == .allFolders,
                    onChanged: (value) {
                      setState(() {
                        folderType = .allFolders;
                      });
                      context.pop();
                    },
                  ),
                ),

                // PopupMenuItem(child: Text("All Folder Tree")),
              ],
            );
          },
          child: Text(folderType.name.toCaptalize),
        ),

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
      ],
    );
  }

  // list,grid,style
  Widget styledList(VideoState state) {
    if (folderType == .allFolders) {
      return folderStyle(state);
    }
    return SliverList.builder(
      itemCount: state.list.length,
      itemBuilder: (context, index) => listItem(state.list[index]),
    );
  }

  Widget folderStyle(VideoState state) {
    final folders = <String, List<VideoFile>>{};
    for (var file in state.list) {
      folders.putIfAbsent(file.dirname, () => []).add(file);
    }
    final folderNames = folders.keys.toList();
    return SliverList.builder(
      itemCount: folderNames.length,
      itemBuilder: (context, index) {
        // final folder = folders[index];
        final name = folderNames[index];
        return VideoFolderListItem(
          folderName: name,
          files: folders[name] ?? [],
          onClicked: (folderName, files) {
            context.push(
              builder: (mainContext) =>
                  VideoFolderListPage(title: name, files: files),
            );
          },
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
