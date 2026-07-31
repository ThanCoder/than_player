import 'dart:io';

import 'package:cfb_store/cfb_store.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart' hide SortButton;
import 'package:than_pkg/than_pkg.dart' hide TPlatform;
import 'package:than_player/core/const_keys.dart';
import 'package:than_player/core/state/all_audio/all_audio_state.dart';
import 'package:than_player/core/state/all_audio/all_audio_state_controller.dart';
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/main/components/audio_sliver_list.dart';
import 'package:than_player/main/home/audio/audio_current_jump_widget.dart';
import 'package:than_player/partials/sort_provider.dart';
import 'package:than_player/settings/audio_setting_page.dart';

class AudioHomePage extends StatefulWidget {
  final bool isCurrentPage;
  const AudioHomePage({super.key, required this.isCurrentPage});

  @override
  State<AudioHomePage> createState() => _AudioHomePageState();
}

class _AudioHomePageState extends State<AudioHomePage> {
  final songListController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (AllAudioStateController.instance.state.list.isNotEmpty) return;
    if (widget.isCurrentPage && !isCalled) {
      init();
    }
    songListController.addListener(_onScrollAndCheckJumpButton);

    AudioStateController.instance.stateStream.listen((_) {
      _onScrollAndCheckJumpButton();
    });
    CFBStore.getInstance.events.listen((event) {
      if (event is PutValue) {
        _onScrollAndCheckJumpButton();
      }
    });
  }

  @override
  void dispose() {
    songListController.dispose();
    super.dispose();
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
      await AllAudioStateController.instance.scanAudioListFromStorageAndCache();
      isCalled = true;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  //******************Current Item ကို ပြန်ပေးတဲ့ button************************** */
  double? viewportHeight;
  void _onScrollAndCheckJumpButton() {
    if (!AudioCurrentJumpWidget.enableNotifier.value) {
      AudioCurrentJumpWidget.enableNotifier.value = true;
    }
    if (viewportHeight != null) {
      if (AudioStateController.instance.currentAudioFile == null) return;

      final id = AudioStateController.instance.currentAudioFile!.id;
      final index = AllAudioStateController.instance.getSongIndexById(id);
      if (index == -1) return;

      final firstVisibleIndex =
          ((songListController.offset) / audioSliverListItemHeight).floor();

      final lastVisibleIndex =
          ((songListController.offset + viewportHeight!) /
                  audioSliverListItemHeight)
              .ceil();
      final itemVisible =
          index >= firstVisibleIndex && index <= lastVisibleIndex;
      if (AudioCurrentJumpWidget.enableNotifier.value != !itemVisible) {
        AudioCurrentJumpWidget.enableNotifier.value = !itemVisible;
      }
    }
  }

  void showCurrentItem() {
    if (AudioStateController.instance.currentAudioFile == null) return;

    final id = AudioStateController.instance.currentAudioFile!.id;
    final index = AllAudioStateController.instance.getSongIndexById(id);
    final offset = (index * audioSliverListItemHeight) - 100;
    // print('index: $index - offset: $offset');

    songListController.jumpTo(
      offset.clamp(
        songListController.position.minScrollExtent,
        songListController.position.maxScrollExtent,
      ),
    );
  }
  //******************Current Item ကို ပြန်ပေးတဲ့ button************************** */

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        viewportHeight = constraints.maxHeight;

        return ValueListenableBuilder(
          valueListenable: AudioSettingPage.valueNotifier,
          builder: (context, value, child) {
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
                                .scanAudioListFromStorageAndCache,
                            icon: Icon(Icons.refresh),
                          ),
                      ],
                    ),
              body: StreamBuilder(
                stream: AudioStateController().stateStream,
                initialData: AudioStateController().state,
                builder: (context, snapshot) {
                  final state = snapshot.data!;

                  return bodyWidget(state);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget bodyWidget(AudioState state) {
    return SafeArea(
      child: Stack(
        children: [
          if (CFBStore.getInstance.getBool(audioBackgroundBlurColorKeyName))
            Positioned.fill(child: backgroundCoverWidget(state)),

          if (CFBStore.getInstance.getBool(audioBackgroundBlurColorKeyName))
            if (state.currentSong != null ||
                AudioStateController.instance.currentCoverCachePath != null ||
                !File(
                  AudioStateController.instance.currentCoverCachePath!,
                ).existsSync())
              Positioned.fill(
                child: BackdropFilter(
                  filter: .blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black.withValues(alpha: .2)),
                ),
              ),
          Positioned.fill(bottom: 0, child: listWidget),

          Positioned(right: 10, bottom: 80, child: songFindIndexWidget),
        ],
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
          return Center(
            child: RefreshButton(text: Text('Refersh'), onClicked: init),
          );
        }
        return RefreshIndicator.adaptive(
          onRefresh: init,
          child: CustomScrollView(
            controller: songListController,
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
              SliverToBoxAdapter(child: SizedBox(height: 70)),
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
          ? const Color.fromARGB(76, 31, 31, 31)
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

  Widget get songFindIndexWidget {
    return AudioCurrentJumpWidget(onTap: showCurrentItem);
  }
}
