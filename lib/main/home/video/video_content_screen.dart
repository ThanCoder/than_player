import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
// import 'package:than_pkg/than_pkg.dart';
import 'package:than_player/core/models/video_file.dart';

class VideoContentScreen extends StatefulWidget {
  final VideoFile file;
  const VideoContentScreen({super.key, required this.file});

  @override
  State<VideoContentScreen> createState() => _VideoContentScreenState();
}

class _VideoContentScreenState extends State<VideoContentScreen> {
  late final player = Player();
  late final controller = VideoController(player);
  bool isKeepProtraitMode = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    player.dispose();
    // if (Platform.isAndroid) {
    //   ThanPkg.android.app.requestOrientation(type: .portrait);
    // }
    super.dispose();
  }

  Future<void> init() async {
    try {
      await player.open(Media(widget.file.path));

      late StreamSubscription<VideoParams> videoParamsSub;
      videoParamsSub = player.stream.videoParams.listen((event) {
        if (player.state.width != null && player.state.height != null) {
          if (player.state.width != null && player.state.height != null) {
            isKeepProtraitMode =
                (player.state.width! / player.state.height!) < 0.8;
            setState(() {});

            videoParamsSub.cancel();
          }
        }
      });
    } catch (e) {
      debugPrint('[_VideoContentScreenState:init]: $e');
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: TPlatform.isDesktop ? AppBar() : null,
        body: Stack(children: [playerWidget]),
      ),
    );
  }

  Widget get playerWidget {
    double videoWidth = MediaQuery.of(context).size.width;
    double videoHeight = MediaQuery.of(context).size.height;
    if (player.state.width != null) {
      videoWidth = player.state.width!.toDouble();
    }
    if (player.state.height != null) {
      videoHeight = player.state.height!.toDouble();
    }

    // print('aspectRatio: ${videoWidth / videoHeight}');
    // print('isKeepProtraitMode: $isKeepProtraitMode');
    return Positioned.fill(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: videoWidth,
          height: videoHeight,
          // Use [Video] widget to display video output.
          child: Video(
            controller: controller,
            onEnterFullscreen: () async {
              if (isKeepProtraitMode) {
                await ThanPkg.platform.toggleFullScreen(isFullScreen: true);
              } else {
                await defaultEnterNativeFullscreen();
              }
            },
            onExitFullscreen: () async {
              if (isKeepProtraitMode) {
                await ThanPkg.platform.toggleFullScreen(isFullScreen: false);
              } else {
                await defaultExitNativeFullscreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
