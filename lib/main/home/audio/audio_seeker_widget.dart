import 'package:flutter/material.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/core/utils/utils.dart';

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
        if (snapshot.data == null || snapshot.data!.duration == null) {
          return SizedBox.shrink();
        }
        final dur = snapshot.data!.duration!;
        final cur = snapshot.data!.updatePosition;

        return Column(
          children: [
            Slider.adaptive(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Text(
                    seekerRangeChanged
                        ? Duration(
                            milliseconds: seekerValue.toInt(),
                          ).formatTimeLable()
                        : cur.formatTimeLable(),
                  ),
                  Spacer(),
                  Text(dur.formatTimeLable()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
