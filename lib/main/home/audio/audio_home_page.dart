import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart' hide SortButton;
import 'package:than_pkg/than_pkg.dart' hide TPlatform;
import 'package:than_player/core/state/all_audio/all_audio_state.dart';
import 'package:than_player/core/state/all_audio/all_audio_state_controller.dart';
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/main/components/audio_sliver_list.dart';
import 'package:than_player/partials/sort_provider.dart';

class AudioHomePage extends StatefulWidget {
  final bool isCurrentPage;
  const AudioHomePage({super.key, required this.isCurrentPage});

  @override
  State<AudioHomePage> createState() => _AudioHomePageState();
}

class _AudioHomePageState extends State<AudioHomePage> {
  @override
  void initState() {
    super.initState();
    if (AllAudioStateController.instance.state.list.isNotEmpty) return;
    if (widget.isCurrentPage && !isCalled) {
      init();
    }
  }

  @override
  void didUpdateWidget(covariant AudioHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (AllAudioStateController.instance.state.list.isNotEmpty) return;
    if (widget.isCurrentPage && !isCalled) {
      init();
    }
  }

  bool isCalled = false;
  Future<void> init() async {
    try {
      if (!await ThanPkg.platform.isStoragePermissionGranted()) {
        await ThanPkg.platform.requestStoragePermission();
        return;
      }
      await AllAudioStateController.instance.scanAudioListFromStorage();
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
      appBar: Platform.isAndroid
          ? null
          : AppBar(
              title: Text('Audio Player'),
              actions: [
                if (TPlatform.isDesktop)
                  IconButton(
                    onPressed: AllAudioStateController
                        .instance
                        .scanAudioListFromStorage,
                    icon: Icon(Icons.refresh),
                  ),
              ],
            ),
      body: StreamBuilder(
        stream: AudioStateController().stateStream,
        initialData: AudioStateController().state,
        builder: (context, snapshot) {
          final state = snapshot.data!;

          return SafeArea(
            child: Stack(
              children: [
                Positioned.fill(child: backgroundCoverWidget(state)),
                if (state.currentSong != null ||
                    AudioStateController.instance.currentCoverCachePath != null)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: .blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        color: Colors.black.withValues(alpha: .2),
                      ),
                    ),
                  ),
                Positioned.fill(
                  bottom: state.showFloatingAudioWidget ? 70 : 0,
                  child: listWidget,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget backgroundCoverWidget(AudioState state) {
    if (state.currentSong == null ||
        AudioStateController.instance.currentCoverCachePath == null) {
      return SizedBox.shrink();
    }
    final coverFile = File(
      AudioStateController.instance.currentCoverCachePath!,
    );
    if (!coverFile.existsSync()) {
      return SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: .4)),

      child: TImageFile(path: coverFile.path),
    );
  }

  Widget get listWidget {
    return StreamBuilder(
      stream: AllAudioStateController.instance.stateStream,
      initialData: AllAudioStateController.instance.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        if (state.isLoading) {
          return Center(child: TLoaderRandom());
        }
        if (state.list.isEmpty) {
          return RefreshButton(text: Text('Refersh'), onClicked: init);
        }
        return RefreshIndicator.adaptive(
          onRefresh: init,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: headerWidget(state)),
              // list
              AudioSliverList(
                list: state.list,
                onClicked: (file) {
                  AudioStateController.instance.setAudioList(state.list);
                  AudioStateController.instance.playTrack(file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget headerWidget(AllAudioState state) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: context.brightness == .dark
          ? const Color.fromARGB(157, 31, 31, 31)
          : const Color.fromARGB(157, 255, 255, 255),
      child: Row(
        children: [
          Text('${state.list.length} Songs'),
          Spacer(),
          StreamBuilder(
            stream: AudioStateController().stateStream,
            builder: (context, asyncSnapshot) {
              return SortButton(
                value: state.sortItem,
                list: AllAudioStateController().sortList,
                onApply: (item) {
                  AllAudioStateController().setSort(item);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
