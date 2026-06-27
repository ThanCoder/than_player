import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart' hide TPlatform;
import 'package:than_player/components/audio_list_item.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
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
    if (!await ThanPkg.platform.isStoragePermissionGranted()) {
      await ThanPkg.platform.requestStoragePermission();
      return;
    }
    await AudioStateController.instance.scanAudioList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          Positioned.fill(child: listWidget),
          Positioned(bottom: 0, left: 0, right: 0, child: playingWidget),
        ],
      ),
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
          child: ListView.separated(
            itemCount: state.list.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) => listItem(state.list[index]),
          ),
        );
      },
    );
  }

  Widget listItem(AudioFile file) {
    return AudioListItem(
      file: file,
      onClicked: (file) {
        AudioStateController.instance.playTrack(
          file.path,
          file.meta.title ?? file.name,
          file.name,
        );
      },
    );
  }

  Widget get playingWidget {
    return PlayingAudioWidget();
  }
}
