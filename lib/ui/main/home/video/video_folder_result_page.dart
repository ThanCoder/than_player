import 'dart:async';
import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state_controller.dart';
import 'package:than_player/core/state/video/video_state_events.dart';
import 'package:than_player/core/utils/video_scanner.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/ui/main/home/video/video_list_style_page_provider.dart';
import 'package:than_player/ui/video/video_list_style_provider.dart';

class VideoFolderResultPage extends StatefulWidget {
  final String title;
  final List<VideoFile> files;
  const VideoFolderResultPage({
    super.key,
    required this.title,
    required this.files,
  });

  @override
  State<VideoFolderResultPage> createState() => _VideoFolderResultPageState();
}

class _VideoFolderResultPageState extends State<VideoFolderResultPage> {
  @override
  void initState() {
    super.initState();
    _sub = VideoStateController.instance.eventStream.listen((event) {
      if (!mounted) return;

      if (event is VideoStateRenameEvent &&
          event.file.dirname == widget.title) {
        rescan();
      }
      if (event is VideoStateRemoveEvent &&
          event.file.dirname == widget.title) {
        rescan();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  StreamSubscription? _sub;
  bool isLoading = false;
  bool rescanCalled = false;
  final List<VideoFile> scannedFiles = [];
  String eventKey = 'video-folder-result-page';

  Future<void> rescan() async {
    try {
      if (widget.files.isEmpty) return;
      final dir = File(widget.files.first.path).parent;
      if (!dir.existsSync()) return;

      scannedFiles.clear();
      setState(() {
        isLoading = true;
        rescanCalled = true;
      });

      await for (var file in dir.list(followLinks: false, recursive: false)) {
        if (file is! File) continue;
        final v = VideoScanner.processEntry(file, file.name);
        if (v == null) continue;
        scannedFiles.add(v);
      }
      VideoStateController.instance.sort(scannedFiles);

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('[_VideoFolderResultPageState:rescan]: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (rescanCalled) {
          VideoStateController.instance.setListWithDirname(
            widget.title,
            scannedFiles,
          );
        }
        context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            VideoListStyleProvider(),
            if (Platform.isLinux)
              IconButton(onPressed: rescan, icon: Icon(Icons.refresh)),
          ],
        ),
        body: isLoading
            ? Center(child: TLoaderRandom())
            : CustomScrollView(slivers: [styledList]),
      ),
    );
  }

  Widget get styledList {
    final files = rescanCalled ? scannedFiles : widget.files;
    return VideoListStylePageProvider(list: files);
  }
}
