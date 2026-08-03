import 'package:flutter/material.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';

class AudioCurrentJumpWidget extends StatelessWidget {
  final void Function()? onTap;
  const AudioCurrentJumpWidget({super.key, this.onTap});

  static final enableNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: enableNotifier,
      builder: (context, buttonEnable, child) {
        if (!buttonEnable) {
          return SizedBox.shrink();
        }
        return StreamBuilder(
          stream: AudioStateController.instance.stateStream,
          builder: (context, snapshot) {
            final current = AudioStateController.instance.currentAudioFile;
            if (current == null) {
              return SizedBox.shrink();
            }
            return FloatingActionButton(
              mini: true,
              onPressed: onTap,
              child: Icon(Icons.track_changes),
            );
          },
        );
      },
    );
  }
}
