import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/ui/audio/audio_blocklist/audio_blocklist_controller.dart';
import 'package:than_player/ui/audio/audio_blocklist/audio_blocklist_view_button.dart';
import 'package:than_player/ui/audio/audio_bookmark/audio_bookmark_controller.dart';
import 'package:than_player/ui/audio/audio_bookmark/audio_bookmark_view_button.dart';
import 'package:than_player/ui/video/video_bookmark/video_bookmark_controller.dart';
import 'package:than_player/ui/video/video_bookmark/video_bookmark_view_button.dart';

class BookmarkPage extends StatefulWidget {
  final bool isCurrentPage;
  const BookmarkPage({super.key, required this.isCurrentPage});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  void initState() {
    super.initState();
    if (widget.isCurrentPage && !isCalled) {
      init();
    }
  }

  @override
  void didUpdateWidget(covariant BookmarkPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrentPage && !isCalled) {
      init();
    }
  }

  bool isCalled = false;
  Future<void> init() async {
    try {
      // if (!await ThanPkg.platform.isStoragePermissionGranted()) {
      //   await ThanPkg.platform.requestStoragePermission();
      //   return;
      // }
      // await AudioStateController.instance.scanAudioList();
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
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: [
            SliverGrid.list(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 230,
                mainAxisExtent: 50,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              children: [
                if (AudioBookmarkController.instance.list.isNotEmpty)
                  AudioBookmarkViewButton(),
                if (VideoBookmarkController.instance.list.isNotEmpty)
                  VideoBookmarkViewButton(),
                if (AudioBlocklistController.instance.list.isNotEmpty)
                  AudioBlocklistViewButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
