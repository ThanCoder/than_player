import 'package:audio_service/audio_service.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/core/utils/utils.dart';

class PlayingAudioWidget extends StatelessWidget {
  const PlayingAudioWidget({super.key});

  @override
  Widget build(BuildContext context) {
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

        return Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 4,
              children: [
                SizedBox(width: 40, height: 40, child: coverWidget(audioFile)),
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
        );
      },
    );
  }

  Widget coverWidget(AudioFile audioFile) {
    return FutureBuilder(
      future: audioFile.meta.readImageCache('${audioFile.name.onlyName}.png'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: TLoaderRandom());
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
      if (meta.title != null)
        Text(meta.title!, style: TextStyle(fontSize: 12))
      else
        Text(
          audioFile.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12),
        ),
      if (playbackEvent.duration != null)
        Text(
          '${playbackEvent.updatePosition.formatTimeLable()}/${playbackEvent.duration!.formatTimeLable()}',
        ),

      // song progress
      songProgressWidget(playbackEvent),
    ];
  }

  Widget handlerWidget(PlaybackEvent playbackEvent) {
    return IconButton(
      onPressed: () {
        AudioStateController.instance.togglePlay();
      },
      icon: Icon(
        AudioStateController.instance.state.isPlaying
            ? Icons.play_arrow
            : Icons.pause,
      ),
    );
  }

  Widget songProgressWidget(PlaybackEvent playbackEvent) {
    return StreamBuilder(
      stream: AudioStateController.instance.playbackEventStream,
      builder: (context, snapshot) {
        final event = snapshot.data;
        if (event != null && event.duration != null ) {
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
