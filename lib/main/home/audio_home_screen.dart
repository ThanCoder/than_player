import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart' hide TPlatform;
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/main/components/audio_list_item.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/main/home/audio/audio_content_page_one.dart';
import 'package:than_player/main/home/audio/playing_audio_widget.dart';

class LinuxAudioHomeScreen extends StatefulWidget {
  const LinuxAudioHomeScreen({super.key});

  @override
  State<LinuxAudioHomeScreen> createState() => _LinuxAudioHomeScreenState();
}

class _LinuxAudioHomeScreenState extends State<LinuxAudioHomeScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    try {
      if (!await ThanPkg.platform.isStoragePermissionGranted()) {
        await ThanPkg.platform.requestStoragePermission();
        return;
      }
      await AudioStateController.instance.scanAudioList();
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !TPlatform.isDesktop
          ? null
          : AppBar(
              title: Text('Audio Player'),
              actions: [
                if (TPlatform.isDesktop)
                  IconButton(
                    onPressed: AudioStateController.instance.scanAudioList,
                    icon: Icon(Icons.refresh),
                  ),
              ],
            ),
      body: Stack(
        children: [
          Positioned.fill(child: backgroundCoverWidget),
          Positioned.fill(child: listWidget),
          Positioned(bottom: 0, left: 0, right: 0, child: playingWidget),
        ],
      ),
    );
  }

  Widget get backgroundCoverWidget {
    return StreamBuilder(
      stream: AudioStateController.instance.stateStream,
      builder: (context, asyncSnapshot) {
        return FutureBuilder(
          future: AudioStateController().currentCoverPath,
          builder: (context, snapshot) {
            final coverFile = File(snapshot.data ?? '');
            if (!coverFile.existsSync()) {
              return SizedBox.fromSize();
            }
            return Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .4),
              ),

              child: TImageFile(path: snapshot.data ?? ''),
            );
          },
        );
      },
    );
  }

  Widget get listWidget {
    return StreamBuilder(
      stream: AudioStateController.instance.stateStream,
      initialData: AudioStateController.instance.state,
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
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: headerWidget(state)),
                // list
                SliverList.builder(
                  itemCount: state.list.length,
                  itemBuilder: (context, index) => listItem(state.list[index]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget headerWidget(AudioState state) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: context.brightness == .dark
          ? const Color.fromARGB(255, 31, 31, 31)
          : Colors.white,
      child: Row(
        children: [
          Text('${state.list.length} Songs'),
          Spacer(),
          IconButton(onPressed: () {}, icon: Icon(Icons.sort)),
        ],
      ),
    );
  }

  Widget listItem(AudioFile file) {
    return AudioListItem(
      file: file,
      onClicked: (file) {
        AudioStateController.instance.playTrack(file);
      },
    );
  }

  Widget get playingWidget {
    return InkWell(
      onTap: () {
        context.push(builder: (mainContext) => AudioContentPageOne());
      },
      child: PlayingAudioWidget(),
    );
  }
}
