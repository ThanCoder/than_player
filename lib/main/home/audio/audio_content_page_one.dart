import 'dart:io';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/core/utils/utils.dart';
import 'package:than_player/main/home/audio/audio_seeker_widget.dart';

class AudioContentPageOne extends StatefulWidget {
  const AudioContentPageOne({super.key});

  @override
  State<AudioContentPageOne> createState() => _AudioContentPageOneState();
}

class _AudioContentPageOneState extends State<AudioContentPageOne> {
  @override
  void initState() {
    if (Platform.isAndroid) {
      ThanPkg.platform.toggleFullScreen(isFullScreen: true);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AudioStateController.instance.stateStream,
      initialData: AudioStateController.instance.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        if (state.currentSong == null) {
          return Placeholder(
            child: Center(child: Text('Current Sone is Null')),
          );
        }
        return Theme(
          data: ThemeData.dark(),
          child: Scaffold(
            appBar: TPlatform.isDesktop ? AppBar() : null,
            body: Stack(
              children: [
                Positioned.fill(child: coverWiget),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .8),
                    ),
                  ),
                ),
                // content
                Positioned.fill(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: SafeArea(child: contentWidget(state)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget get coverWiget {
    return FutureBuilder(
      future: AudioStateController.instance.currentCoverPath,
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

  Widget contentWidget(AudioState state) {
    final currentAudioFile = AudioStateController.instance.currentAudioFile!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // 💡 ပြင်ဆင်ချက်: Content ထဲက ပုံကို Size အသေ ကန့်သတ်ပြီး Shadow လေး ထည့်ပေးမယ်
          Center(
            child: Container(
              width: 280, // Music App တွေရဲ့ Standard ပုံအရွယ်အစား
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: coverWiget, // သင့်ရဲ့ ရုပ်ပုံ Widget
              ),
            ),
          ),
          const SizedBox(height: 40),

          // သီချင်းခေါင်းစဉ်နှင့် အဆိုတော်အမည်
          marqueeWidget(currentAudioFile.meta.title ?? currentAudioFile.name),
          const SizedBox(height: 8),
          if (currentAudioFile.meta.artist != null)
            Text(
              currentAudioFile.meta.artist ?? 'Unknown Artist',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          if (currentAudioFile.meta.album != null)
            Text(
              currentAudioFile.meta.album ?? 'Unknown Album',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),

          Spacer(),
          controlsWidget(state),
          AudioSeekerWidget(),
          const SizedBox(height: 5),
          menuWidget,
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget controlsWidget(AudioState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 3,
      children: [
        IconButton(
          onPressed: AudioStateController.instance.prev,
          icon: Icon(Icons.skip_previous_rounded, size: 40),
        ),
        IconButton(
          onPressed: AudioStateController.instance.togglePlay,
          icon: Icon(
            state.isPlaying
                ? Icons.pause_circle_outlined
                : Icons.play_circle_outline,
            size: 70,
          ),
        ),
        IconButton(
          onPressed: AudioStateController.instance.next,
          icon: Icon(Icons.skip_next, size: 40),
        ),
      ],
    );
  }

  Widget get menuWidget {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(onPressed: () {}, icon: Icon(Icons.timelapse)),
        IconButton(onPressed: () {}, icon: Icon(Icons.favorite)),
        IconButton(onPressed: () {}, icon: Icon(Icons.list)),
      ],
    );
  }

  Widget marqueeWidget(String title) {
    return SizedBox(
      height: 32, // Marquee သုံးရင် height အသေတစ်ခု ပေးရပါမယ်
      child: Marquee(
        text: title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        scrollAxis: Axis.horizontal, // ဘေးတိုက်ရွေ့မည်
        crossAxisAlignment: CrossAxisAlignment.start,
        blankSpace: 50.0, // စာတန်းအဆုံးနဲ့ အစ ပြန်မစခင် ကြားကအကွာအဝေး
        velocity: 30.0, // စာလုံး ပြေးမယ့်အရှိန် (များရင် ပိုမြန်တယ်)
        pauseAfterRound: const Duration(
          seconds: 2,
        ), // စာတစ်ခေါက်ပြီးရင် ၂ စက္ကန့် ခဏရပ်မည်
        startPadding: 10.0,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}
