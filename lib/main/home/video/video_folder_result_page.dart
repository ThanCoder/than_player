import 'dart:async';
import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state_controller.dart';
import 'package:than_player/core/state/video/video_state_events.dart';
import 'package:than_player/core/utils/video_scanner.dart';
import 'package:than_player/main/home/video/video_list_style_provider.dart';
import 'package:than_player/partials/list_style_provider.dart';

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
    _stateSub = VideoStateController.instance.eventStream.listen((event) {
      if (!mounted) return;
      if (currentPageFetched) return;
      if (!rescanCalled) {
        rescan();
        return;
      }

      if (event is VideoStateRemoveEvent) {
        final index = scanedFiles.indexWhere((e) => e.id == event.file.id);
        if (index == -1) return;
        scanedFiles.removeAt(index);
        setState(() {});
      } else if (event is VideoStateRenameEvent) {
        final index = scanedFiles.indexWhere((e) => e.id == event.file.id);
        if (index == -1) return;
        scanedFiles[index] = event.file;
        setState(() {});
      } else if (event is VideoStateAddEvent) {
        final index = scanedFiles.indexWhere((e) => e.id == event.file.id);
        if (index != -1) return;
        scanedFiles.add(event.file);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  StreamSubscription? _stateSub;
  bool isLoading = false;
  bool rescanCalled = false;
  bool currentPageFetched = false;
  final List<VideoFile> scanedFiles = [];

  Future<void> rescan() async {
    try {
      if (widget.files.isEmpty) return;
      final dir = File(widget.files.first.path).parent;
      if (!dir.existsSync()) return;

      scanedFiles.clear();
      setState(() {
        isLoading = true;
        rescanCalled = true;
      });

      await for (var file in dir.list(followLinks: false, recursive: false)) {
        if (file is! File) continue;
        final v = VideoScanner.processEntry(file, file.name);
        if (v == null) continue;
        scanedFiles.add(v);
      }

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      // update state
      handleGlobalState();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ListStyleProvider(),
          if (Platform.isLinux)
            IconButton(onPressed: rescan, icon: Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? Center(child: TLoaderRandom())
          : CustomScrollView(slivers: [styledList]),
    );
  }

  Widget get styledList {
    final files = rescanCalled ? scanedFiles : widget.files;
    return VideoListStyleProvider(list: files);
  }

  void handleGlobalState() {
    currentPageFetched = true;
    // 2. Global State Controller ကို Update လုပ်ရန် နှိုင်းယှဉ်ခြင်း (Comparison Logic)

    // A. ပျောက်သွားသော/ဖျက်လိုက်သော ဖိုင်များကို ရှာပြီး Delete လုပ်ခြင်း
    final scannedPaths = scanedFiles.map((e) => e.path).toSet();
    final deletedFiles = widget.files
        .where((oldFile) => !scannedPaths.contains(oldFile.path))
        .toList();

    for (var file in deletedFiles) {
      VideoStateController.instance.removeVideoState(file);
    }

    // B. နာမည် သို့မဟုတ် Details ပြောင်းသွားသော/အသစ်ရောက်လာသော ဖိုင်များကို Check လုပ်ခြင်း
    for (var newFile in scanedFiles) {
      // path တူတဲ့ ဖိုင်အဟောင်း ရှိမရှိ ရှာမယ်
      final existingIndex = widget.files.indexWhere(
        (oldFile) => oldFile.path == newFile.path,
      );

      if (existingIndex != -1) {
        final existingFile = scanedFiles[existingIndex];

        // Path တူပေမဲ့ နာမည်/Size/Date ပြောင်းသွားရင် Update လုပ်မယ်
        if (existingFile.name != newFile.name ||
            existingFile.size != newFile.size ||
            existingFile.date != newFile.date) {
          VideoStateController.instance.renameVideoState(newFile);
        }
      } else {
        VideoStateController.instance.addVideo(newFile);
      }
    }
    // stream ပြီးတဲ့အထိစောင့်ပြီးတော့ တားထားမယ်
    // ဒီ page ကနေ state ကိုပြင်နေရင် အပေါ်က stream lister က အလုပ်မလုပ်ဘူး
    Future.delayed(Duration(seconds: 1)).then((_) {
      currentPageFetched = false;
    });
  }
}
