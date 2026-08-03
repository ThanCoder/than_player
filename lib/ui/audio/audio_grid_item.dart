import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/ui/audio/audio_bookmark/audio_bookmark_button.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/extensions/build_context_exts.dart';

class AudioGridItem extends StatelessWidget {
  final AudioFile file;
  final void Function(AudioFile file)? onClicked;
  final void Function(AudioFile file)? onMenuClicked;
  const AudioGridItem({
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
      child: StreamBuilder(
        stream: AudioStateController().stateStream,
        initialData: AudioStateController().state,
        builder: (context, snapshot) {
          final state = snapshot.data!;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: itemBoxDecoration(context, file),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Row(
                  spacing: 4,
                  children: [
                    SizedBox(width: 100, height: 60, child: leftWidget(state)),
                    Expanded(child: metaWidget),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration itemBoxDecoration(BuildContext context, AudioFile file) {
    final isCurrent = AudioStateController.instance.isCurrentSong(file.id);
    if (isCurrent) {
      // return const Color.fromARGB(237, 1, 31, 27);
      // 🔥 မီးလောင်နေတဲ့ / Fire Glow Style
      return BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // ရဲရဲတောက် မီးတောက် Gradient စပ်ထားခြင်း (Dark Red -> Deep Orange -> Fire Gold)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            if (context.brightness.isDark)
              Color(0xFF8B0000)
            else
              Color.fromARGB(200, 196, 38, 38), // Dark Red
            if (context.brightness.isDark)
              Color(0xFFFF4500)
            else
              Color.fromARGB(148, 255, 68, 0), // Orange Red
            if (context.brightness.isDark)
              Color(0xFFFFA500)
            else
              Color.fromARGB(181, 255, 166, 0), // Flame Gold
          ],
        ),
        // မီးရောင် မှိတ်တုတ်မှိတ်တုတ်/လင်းနေမယ့် Neon Glow Shadow
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4500).withValues(alpha: 0.6),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      return BoxDecoration(
        borderRadius: .circular(12),
        color: context.brightness.isDark
            ? const Color.fromARGB(205, 18, 13, 13)
            : const Color.fromARGB(192, 244, 228, 228),
      );
    }
  }

  Widget get metaWidget {
    final meta = file.meta;

    return Column(
      spacing: 0,
      crossAxisAlignment: .start,
      children: [
        Text(
          file.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text(meta.formatDuration, style: TextStyle(fontSize: 11)),
            AudioBookmarkButton(file: file, iconSize: 20),
            if (meta.artist.isNotEmpty)
              Expanded(
                child: Text(
                  ' - ${meta.artist}',
                  maxLines: 1,
                  style: TextStyle(fontSize: 11),
                ),
              ),
          ],
        ),
        // audio info
        if (meta.bitrate != 0 && meta.sampleRate != 0)
          Text(
            '${meta.formatLabel} * ${meta.bitrateLabel} * ${meta.sampleRateLabel}',
            style: TextStyle(fontSize: 11),
          ),
      ],
    );
  }

  Widget leftWidget(AudioState state) {
    final isCurrent =
        state.currentSong != null &&
        state.currentSong!.id == file.id &&
        state.isPlaying;
    return Stack(
      children: [
        Positioned.fill(child: coverWidget),
        if (isCurrent) Container(color: Colors.black.withValues(alpha: .5)),
        if (isCurrent)
          Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            child: LottieBuilder.asset(
              'assets/lotties/Playing.lottie',
              fit: BoxFit.fitHeight,
              // Animation အမြဲပတ်နေစေရန်
              repeat: true,
              animate: true,
            ),
          ),
      ],
    );
  }

  Widget get coverWidget {
    return TImageFile(path: file.cacheCoverPath, fit: .cover);
  }
}
