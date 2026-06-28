import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/extensions/build_context_exts.dart';

class AudioListItem extends StatelessWidget {
  final AudioFile file;
  final void Function(AudioFile file)? onClicked;
  final void Function(AudioFile file)? onMenuClicked;
  const AudioListItem({
    super.key,
    required this.file,
    this.onClicked,
    this.onMenuClicked,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AudioStateController().stateStream,
      initialData: AudioStateController().state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        return InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () => onClicked?.call(file),
          onLongPress: () => onMenuClicked?.call(file),
          onSecondaryTap: () => onMenuClicked?.call(file),
          child: Card(
            color:
                state.currentSong != null && state.currentSong!.id == file.name
                ? const Color.fromARGB(235, 18, 172, 159)
                : context.brightness == .dark
                ? Colors.black.withValues(alpha: .5)
                : Colors.white.withValues(alpha: .7),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                spacing: 4,
                children: [
                  SizedBox(
                    width: Platform.isAndroid ? 50 : 90,
                    height: Platform.isAndroid ? 50 : 90,
                    child: stateWidget(state),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(
                          file.name,
                          maxLines: Platform.isAndroid ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        metaWidget,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get metaWidget {
    final meta = file.meta;

    return Row(
      children: [
        if (meta.duration != null) Text(meta.formatDuration),
        IconButton(onPressed: () {}, icon: Icon(Icons.favorite, size: 20)),
        if (meta.artist != null)
          Expanded(child: Text(' - ${meta.artist!}', maxLines: 1)),
      ],
    );
  }

  Widget stateWidget(AudioState state) {
    return Stack(
      children: [
        Positioned.fill(child: coverWidget),
        Container(
          decoration: BoxDecoration(
            // color: Colors.black.withValues(alpha: .4),
          ),
        ),
        if (state.currentSong != null && state.currentSong!.id == file.name)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Icon(
              state.isPlaying ? Icons.play_circle : Icons.pause_circle,
            ),
          ),
      ],
    );
  }

  Widget get coverWidget {
    return FutureBuilder(
      future: file.meta.readImageCache(file.cacheName),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: TLoader());
        }
        final cachePath = snapshot.data!;
        // print(cachePath);
        return TImageFile(path: cachePath);
      },
    );
  }
}
