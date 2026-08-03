import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/all_audio/all_audio_state_controller.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/ui/audio/audio_blocklist/audio_blocklist_controller.dart';
import 'package:than_player/ui/audio/audio_sliver_list.dart';
import 'package:than_player/ui/main/home/audio/playing_audio_widget.dart';

class AudioBlocklistViewPage extends StatefulWidget {
  const AudioBlocklistViewPage({super.key});

  @override
  State<AudioBlocklistViewPage> createState() => _AudioBlocklistViewPageState();
}

class _AudioBlocklistViewPageState extends State<AudioBlocklistViewPage> {
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // controller.addListener(checkGotoButton);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        actions: [
          if (TPlatform.isDesktop)
            IconButton(
              onPressed: AudioStateController.instance.init,
              icon: Icon(Icons.refresh),
            ),
        ],
      ),
      body: StreamBuilder(
        stream: AudioStateController.instance.stateStream,
        builder: (context, asyncSnapshot) {
          return Stack(
            children: [
              Positioned.fill(
                bottom: 0,
                child: CustomScrollView(
                  controller: controller,
                  slivers: [
                    StreamBuilder(
                      stream: AudioBlocklistController().stream,
                      builder: (context, asyncSnapshot) {
                        return AudioSliverList(
                          list: AudioBlocklistController().list,
                          onClicked: showUnblockConfirmMenu,
                          onMenuClicked: (file) {},
                        );
                      },
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 70)),
                  ],
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: PlayingAudioWidget(),
              ),
            ],
          );
        },
      ),
    );
  }

  void showUnblockConfirmMenu(AudioFile file) {
    showTConfirmDialog(
      context,
      contentText: 'Do You Want To `UnBlock`',
      submitText: 'UnBlock',
      onSubmit: () {
        AllAudioStateController.instance.removeBlockList(file);
      },
    );
  }
}
