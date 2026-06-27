import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';

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
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () => onClicked?.call(file),
      onLongPress: () => onMenuClicked?.call(file),
      onSecondaryTap: () => onMenuClicked?.call(file),
      child: Row(
        spacing: 4,
        children: [
          SizedBox(width: 90, height: 90, child: stateWidget),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
                ...metaWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get metaWidget {
    final meta = file.meta;

    return [
      if (meta.title != null) Text(meta.title!),
      if (meta.duration != null) Text(meta.formatDuration),
    ];
  }

  Widget get stateWidget {
    return StreamBuilder(
      stream: AudioStateController().stateStream,
      initialData: AudioStateController().state,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        return Stack(
          children: [
            Positioned.fill(child: coverWidget),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .4),
              ),
            ),
            if (state.currentSong != null && state.currentSong!.id == file.name)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Text(
                  state.isPlaying ? 'Playing...' : 'Stop',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget get coverWidget {
    return FutureBuilder(
      future: file.meta.readImageCache('${file.name.onlyName}.png'),
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
}
