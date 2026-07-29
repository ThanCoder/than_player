import 'package:audio_service/audio_service.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/main/home/audio/audio_content_page_one.dart';

class PlayingAudioWidget extends StatelessWidget {
  const PlayingAudioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: .circular(15),
      child: BackdropFilter(
        filter: .blur(sigmaX: 10, sigmaY: 10),
        child: StreamBuilder(
          stream: AudioStateController().stateStream,
          initialData: AudioStateController().state,
          builder: (context, snapshot) {
            final state = snapshot.data!;
            if (!state.showFloatingAudioWidget) {
              return SizedBox.shrink();
            }
            return StreamBuilder(
              stream: AudioStateController.instance.playbackEventStream,
              builder: (context, snapshot) {
                PlaybackEvent? playbackEvent = snapshot.data;
                if (playbackEvent == null) {
                  return SizedBox.fromSize();
                }
                MediaItem? currentSong =
                    AudioStateController.instance.state.currentSong;
                if (currentSong == null) {
                  return SizedBox.fromSize();
                }
                final audioFile = AudioStateController().getAudioFileById(
                  currentSong.id,
                );
                if (audioFile == null) {
                  return SizedBox.fromSize();
                }
                return InkWell(
                  onTap: () => context.push(
                    builder: (mainContext) => AudioContentPageOne(),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.brightness == .dark
                          ? const Color.fromARGB(71, 15, 15, 15)
                          : const Color.fromARGB(75, 255, 255, 255),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        spacing: 4,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: coverWidget(audioFile),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 3,
                              children: metaWidget(audioFile, playbackEvent),
                            ),
                          ),
                          handlerWidget(playbackEvent),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget coverWidget(AudioFile audioFile) {
    return FutureBuilder(
      future: audioFile.meta.readImageCache('${audioFile.name.onlyName}.png'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(width: 50, height: 50, child: TLoaderRandom()),
          );
        }
        final cachePath = snapshot.data!;
        // print(cachePath);
        return TImageFile(path: cachePath);
      },
    );
  }

  List<Widget> metaWidget(AudioFile audioFile, PlaybackEvent playbackEvent) {
    final meta = audioFile.meta;

    return [
      SizedBox(
        width: double.infinity,
        height: 20,
        child: Marquee(
          text: meta.title ?? audioFile.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      if (meta.artist != null) Text(meta.artist!, maxLines: 1),

      // song progress
      songProgressWidget(playbackEvent),
    ];
  }

  Widget handlerWidget(PlaybackEvent playbackEvent) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            AudioStateController.instance.togglePlay();
          },
          icon: Icon(
            AudioStateController.instance.state.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
          ),
        ),
        IconButton(
          onPressed: () {
            AudioStateController().setVisiableFloatingAudioWidget(false);
          },
          icon: Icon(Icons.close),
        ),
      ],
    );
  }

  Widget songProgressWidget(PlaybackEvent playbackEvent) {
    return StreamBuilder(
      stream: AudioStateController.instance.playbackEventStream,
      builder: (context, snapshot) {
        final event = snapshot.data;
        if (event != null && event.duration != null) {
          // print(event);
          final dur = event.duration!.inMilliseconds;
          final cur = event.updatePosition.inMilliseconds;
          return LinearProgressIndicator(value: cur / dur);
        }

        return SizedBox.fromSize();
      },
    );
  }
}
