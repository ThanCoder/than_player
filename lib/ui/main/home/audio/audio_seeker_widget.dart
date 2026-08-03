import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';

class AudioSeekerWidget extends StatefulWidget {
  const AudioSeekerWidget({super.key});

  @override
  State<AudioSeekerWidget> createState() => _AudioSeekerWidgetState();
}

class _AudioSeekerWidgetState extends State<AudioSeekerWidget> {
  double seekerValue = 0;
  bool seekerRangeChanged = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AudioStateController.instance.playbackEventStream,
      builder: (context, snapshot) {
        var dur = Duration.zero;
        var cur = Duration.zero;
        if (snapshot.data != null && snapshot.data!.duration != null) {
          dur = snapshot.data!.duration!;
          cur = snapshot.data!.updatePosition;
        }
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: const Color.fromARGB(255, 244, 54, 98),
                inactiveTrackColor: const Color.fromARGB(138, 153, 36, 27),
                thumbShape: .noThumb,
                // overlayColor: color.withValues(alpha: 0.15),
              ),
              child: Slider.adaptive(
                min: 0,
                max: dur.inMilliseconds.toDouble(),
                value: seekerRangeChanged
                    ? seekerValue
                    : cur.inMilliseconds.toDouble(),
                onChangeStart: (value) {
                  setState(() {
                    seekerRangeChanged = true;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    seekerValue = value;
                  });
                },
                onChangeEnd: (value) {
                  setState(() {
                    seekerRangeChanged = false;
                  });
                  AudioStateController.instance.seek(
                    Duration(milliseconds: seekerValue.toInt()),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Text(
                    seekerRangeChanged
                        ? Duration(
                            milliseconds: seekerValue.toInt(),
                          ).formatClockLabel()
                        : cur.formatClockLabel(),
                  ),
                  Spacer(),
                  Text(dur.formatClockLabel()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
