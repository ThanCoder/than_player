import 'package:flutter/material.dart';
import 'package:than_player/audio_bookmark/audio_bookmark_controller.dart';
import 'package:than_player/core/state/all_audio/all_audio_state_controller.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/main/components/audio_sliver_list.dart';
import 'package:than_player/main/home/audio/playing_audio_widget.dart';

class AudioBookmarkViewPage extends StatefulWidget {
  const AudioBookmarkViewPage({super.key});

  @override
  State<AudioBookmarkViewPage> createState() => _AudioBookmarkViewPageState();
}

class _AudioBookmarkViewPageState extends State<AudioBookmarkViewPage> {
  @override
  void initState() {
    super.initState();
    if (AllAudioStateController.instance.state.list.isEmpty) {
      AllAudioStateController.instance.scanAudioListFromStorage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        stream: AudioStateController().stateStream,
        builder: (context, asyncSnapshot) {
          return Stack(
            children: [
              Positioned.fill(
                bottom:
                    AudioStateController.instance.state.showFloatingAudioWidget
                    ? 70
                    : 0,
                child: CustomScrollView(
                  slivers: [
                    StreamBuilder(
                      stream: AllAudioStateController().stateStream,
                      builder: (context, snapshot) {
                        return StreamBuilder(
                          stream: AudioBookmarkController().stream,
                          builder: (context, asyncSnapshot) {
                            return AudioSliverList(
                              list: AudioBookmarkController().getAudioFiles(),
                              onClicked: (file) {
                                AudioStateController.instance.setAudioList(
                                  AudioBookmarkController().getAudioFiles(),
                                );
                                AudioStateController.instance.playTrack(file);
                              },
                            );
                          },
                        );
                      },
                    ),
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
}
