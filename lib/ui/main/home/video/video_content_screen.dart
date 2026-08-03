import 'dart:async';
import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart' show ThanPkg;
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/ui/video/video_config/video_config.dart';

class VideoContentScreen extends StatefulWidget {
  final VideoFile file;
  final int? currentPositionInMiliseconds;
  const VideoContentScreen({
    super.key,
    required this.file,
    this.currentPositionInMiliseconds,
  });

  @override
  State<VideoContentScreen> createState() => _VideoContentScreenState();
}

class _VideoContentScreenState extends State<VideoContentScreen> {
  late final player = Player();
  late final controller = VideoController(player);
  bool isKeepProtraitMode = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
    init();
  }

  @override
  void dispose() {
    player.dispose();
    focusNode.dispose();
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    super.dispose();
  }

  Future<void> init() async {
    try {
      // stop audio
      await AudioStateController.instance.pause();

      await player.open(Media(widget.file.path));

      await controller.waitUntilFirstFrameRendered;

      if (player.state.width != null && player.state.height != null) {
        if (player.state.width != null && player.state.height != null) {
          isKeepProtraitMode =
              (player.state.width! / player.state.height!) < 0.8;

          setState(() {});
        }
      }
      // Duration မရှိသေးရင် ခဏစောင့်မည်
      if (player.state.duration == Duration.zero) {
        await player.stream.duration.firstWhere((d) => d > Duration.zero);
      }
      await player.stream.buffer.first;

      // seek
      if (widget.currentPositionInMiliseconds != null &&
          widget.currentPositionInMiliseconds != 0) {
        // await Future.delayed(Duration(milliseconds: 1200));
        await player.seek(
          Duration(milliseconds: widget.currentPositionInMiliseconds!),
        );
      }
    } catch (e) {
      debugPrint('[_VideoContentScreenState:init]: $e');
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onPlayerClosed();
      },
      child: Theme(
        data: ThemeData.dark(),
        child: Scaffold(
          appBar: TPlatform.isDesktop ? AppBar() : null,
          body: Stack(children: [playerWidget]),
        ),
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
          child: videoWidget,
        ),
      ),
    );
  }

  Widget get videoWidget {
    return Video(
      focusNode: focusNode,
      controller: controller,
      controls: (state) => Platform.isLinux
          ? MaterialDesktopVideoControls(state)
          : MaterialVideoControls(state),
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
    );
  }

  Future<void> onPlayerClosed() async {
    final duration = controller.player.state.duration;
    final current = controller.player.state.position;

    await player.stop();
    if (!mounted) return;
    context.pop<VideoConfig>(VideoConfig(duration: duration, current: current));
  }
}
