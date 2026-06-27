import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';

class PlayingAudioWidget extends StatelessWidget {
  const PlayingAudioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AudioStateController().stateStream,
      initialData: AudioStateController().state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        MediaItem? currentSong = state.currentSong;
        if (currentSong == null) {
          return SizedBox.fromSize();
        }
        return Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 4,
              children: [
                // SizedBox(width: 90, height: 90, child: stateWidget),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        currentSong.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                      // ...metaWidget,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget coverWidget(MediaItem item) {
  //   return FutureBuilder(
  //     future: file.meta.readImageCache('${file.name.onlyName}.png'),
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData) {
  //         return Center(child: TLoaderRandom());
  //       }
  //       final cachePath = snapshot.data!;
  //       // print(cachePath);
  //       return TImageFile(path: cachePath);
  //     },
  //   );
  // }
}
