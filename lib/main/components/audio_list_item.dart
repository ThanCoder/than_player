import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/audio_bookmark/audio_bookmark_button.dart';
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
    // print('current: ${AudioStateController.instance.isCurrentSong(file.id)}');
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
            color: itemBackgroundColor(context, file),
            child: ClipRRect(
              borderRadius: .circular(12),
              child: BackdropFilter(
                filter: .blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    spacing: 4,
                    children: [
                      SizedBox(
                        width: Platform.isAndroid ? 40 : 60,
                        height: Platform.isAndroid ? 40 : 60,
                        child: stateWidget(state),
                      ),
                      Expanded(child: metaWidget),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color? itemBackgroundColor(BuildContext context, AudioFile file) {
    if (AudioStateController.instance.isCurrentSong(file.id)) {
      return Colors.teal;
    } else {
      return context.brightness.isDark
          ? const Color.fromARGB(60, 0, 0, 0)
          : const Color.fromARGB(88, 222, 222, 222);
    }
  }

  Widget get metaWidget {
    final meta = file.meta;

    return Column(
      spacing: 1,
      crossAxisAlignment: .start,
      children: [
        Text(
          file.name,
          maxLines: Platform.isAndroid ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            if (meta.duration != null)
              Text(meta.formatDuration, style: TextStyle(fontSize: 11)),
            AudioBookmarkButton(file: file, iconSize: 20),
            if (meta.artist != null)
              Expanded(
                child: Text(
                  ' - ${meta.artist!}',
                  maxLines: 1,
                  style: TextStyle(fontSize: 11),
                ),
              ),
          ],
        ),
        // audio info
        if (meta.info != null)
          Text(
            '${meta.formatLabel} * ${meta.bitrateLabel} * ${meta.sampleRateLabel}',
            style: TextStyle(fontSize: 11),
          ),
      ],
    );
  }

  Widget stateWidget(AudioState state) {
    return Stack(
      children: [
        Positioned.fill(child: coverWidget),
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
        return TImageFile(path: cachePath);
      },
    );
  }
}
