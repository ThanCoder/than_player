import 'package:flutter/material.dart';
import 'package:than_player/core/const_keys.dart';
import 'package:than_player/ui/audio/audio_bookmark/audio_bookmark_controller.dart';
import 'package:than_player/core/state/all_audio/all_audio_state_controller.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/ui/audio/audio_sliver_list.dart';
import 'package:than_player/ui/main/home/audio/playing_audio_widget.dart';

class AudioBookmarkViewPage extends StatefulWidget {
  const AudioBookmarkViewPage({super.key});

  @override
  State<AudioBookmarkViewPage> createState() => _AudioBookmarkViewPageState();
}

class _AudioBookmarkViewPageState extends State<AudioBookmarkViewPage> {
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    if (AllAudioStateController.instance.state.list.isEmpty) {
      AllAudioStateController.instance.scanAudioListFromStorageAndCache();
    }
    controller.addListener(checkGotoButton);
  }

  final audioCurrentJumpWidgetShowNotifier = ValueNotifier<bool>(false);
  double? viewportHeight;

  void checkGotoButton() {
    if (!audioCurrentJumpWidgetShowNotifier.value) {
      audioCurrentJumpWidgetShowNotifier.value = true;
    }
    if (viewportHeight != null) {
      if (AudioStateController.instance.currentAudioFile == null) return;

      final id = AudioStateController.instance.currentAudioFile!.id;
      final index = AudioBookmarkController.instance.getSongIndexById(id);
      if (index == -1) return;

      final firstVisibleIndex =
          ((controller.offset) / audioSliverListItemHeight).floor();

      final lastVisibleIndex =
          ((controller.offset + viewportHeight!) / audioSliverListItemHeight)
              .ceil();
      final itemVisible =
          index >= firstVisibleIndex && index <= lastVisibleIndex;
      if (audioCurrentJumpWidgetShowNotifier.value != !itemVisible) {
        audioCurrentJumpWidgetShowNotifier.value = !itemVisible;
      }
    }
  }

  void goCurrentItem() {
    if (AudioStateController.instance.currentAudioFile == null) return;

    final id = AudioStateController.instance.currentAudioFile!.id;
    final index = AudioBookmarkController.instance.getSongIndexById(id);
    final offset = (index * audioSliverListItemHeight) - 100;
    // print('index: $index - offset: $offset');

    controller.jumpTo(
      offset.clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          viewportHeight = constraints.maxHeight;
          return StreamBuilder(
            stream: AudioStateController().stateStream,
            builder: (context, asyncSnapshot) {
              return Stack(
                children: [
                  Positioned.fill(
                    bottom: 0,
                    child: CustomScrollView(
                      controller: controller,
                      slivers: [
                        StreamBuilder(
                          stream: AllAudioStateController().stateStream,
                          builder: (context, snapshot) {
                            return StreamBuilder(
                              stream: AudioBookmarkController().stream,
                              builder: (context, asyncSnapshot) {
                                return AudioSliverList(
                                  list: AudioBookmarkController()
                                      .getAudioFiles(),
                                  onClicked: (file) {
                                    AudioStateController.instance.setAudioList(
                                      AudioBookmarkController().getAudioFiles(),
                                    );
                                    AudioStateController.instance.playTrack(
                                      file,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 70)),
                      ],
                    ),
                  ),
                  Positioned(right: 0, bottom: 80, child: gotoButtonWidget),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: PlayingAudioWidget(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget get gotoButtonWidget {
    return ValueListenableBuilder(
      valueListenable: audioCurrentJumpWidgetShowNotifier,
      builder: (context, isEnable, child) {
        if (!isEnable) {
          return SizedBox.shrink();
        }
        return FloatingActionButton(
          mini: true,
          onPressed: goCurrentItem,
          child: Icon(Icons.track_changes),
        );
      },
    );
  }
}
