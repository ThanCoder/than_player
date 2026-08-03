import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:palette_generator_master/palette_generator_master.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/ui/audio/audio_bookmark/audio_bookmark_button.dart';
import 'package:than_player/core/state/audio/audio_state.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/ui/main/home/audio/audio_seeker_widget.dart';

class AudioContentPageOne extends StatefulWidget {
  const AudioContentPageOne({super.key});

  @override
  State<AudioContentPageOne> createState() => _AudioContentPageOneState();
}

class _AudioContentPageOneState extends State<AudioContentPageOne> {
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
                      color: context.brightness.isDark
                          ? Colors.black.withValues(alpha: .4)
                          : Colors.white.withValues(alpha: .4),

                      gradient: LinearGradient(
                        begin: .topCenter,
                        end: .bottomCenter,
                        colors: [
                          const Color.fromARGB(255, 14, 66, 16),
                          const Color.fromARGB(255, 41, 105, 158),
                          const Color.fromARGB(255, 142, 28, 125),
                          if (context.brightness.isDark)
                            const Color.fromARGB(223, 39, 36, 36)
                          else
                            const Color.fromARGB(224, 212, 207, 207),
                          if (context.brightness.isDark)
                            const Color.fromARGB(177, 0, 0, 0)
                          else
                            Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // content
                Positioned.fill(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: .blur(sigmaX: 10, sigmaY: 10),
                        child: contentWidget(state),
                      ),
                    ),
                  ),
                ),
                // controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: controlsWidget(state),
                ),
                // appbar background
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 40,
                  child: appbarBackgroundWidget,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget get appbarBackgroundWidget {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            if (context.brightness.isDark)
              Colors.red
            else
              const Color.fromARGB(255, 212, 119, 113),
            if (context.brightness.isDark)
              Colors.blue
            else
              const Color.fromARGB(255, 96, 179, 195),
            if (context.brightness.isDark)
              Colors.blue
            else
              const Color.fromARGB(255, 237, 129, 233),
            if (context.brightness.isDark)
              Colors.green
            else
              const Color.fromARGB(255, 120, 194, 112),
          ],
        ),
      ),
    );
  }

  Widget get coverWiget {
    return TImageFile(
      path: AudioStateController.instance.currentCoverPath,
      fit: .fitHeight,
    );
  }

  Widget contentWidget(AudioState state) {
    final currentAudioFile = AudioStateController.instance.currentAudioFile!;

    return Container(
      margin: EdgeInsets.only(top: 50),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 5,
        children: [
          Center(
            child: CoverHeaderBox(
              coverPath: currentAudioFile.cacheCoverPath,
              coverWiget: coverWiget,
            ),
          ),

          // သီချင်းခေါင်းစဉ်နှင့် အဆိုတော်အမည်
          marqueeWidget(currentAudioFile.autoTitle),
          // const SizedBox(height: 8),
          // content scrollable
          scrollableContent(state),

          // const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget scrollableContent(AudioState state) {
    final currentAudioFile = AudioStateController.instance.currentAudioFile!;
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (currentAudioFile.meta.artist.isNotEmpty)
              Text(
                currentAudioFile.meta.artist.isNotEmpty
                    ? currentAudioFile.meta.artist
                    : 'Unknown Artist',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            if (currentAudioFile.meta.album.isNotEmpty)
              Text(
                currentAudioFile.meta.album.isNotEmpty
                    ? currentAudioFile.meta.album
                    : 'Unknown Album',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  // controls
  Widget controlsWidget(AudioState state) {
    final meta = AudioStateController().currentAudioFile!.meta;
    return Column(
      children: [
        Wrap(
          alignment: .center,
          crossAxisAlignment: .center,
          spacing: 3,
          children: [
            IconButton(
              onPressed:
                  !AudioStateController.instance.existsByIndex(
                    AudioStateController.instance.currentSongIndex - 1,
                  )
                  ? null
                  : AudioStateController.instance.prev,
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
              onPressed:
                  !AudioStateController.instance.existsByIndex(
                    AudioStateController.instance.currentSongIndex + 1,
                  )
                  ? null
                  : AudioStateController.instance.next,
              icon: Icon(Icons.skip_next, size: 40),
            ),
          ],
        ),
        AudioSeekerWidget(),
        // audio info
        Text(
          '${meta.formatLabel} * ${meta.bitrateLabel} * ${meta.sampleRateLabel}',
        ),
        const SizedBox(height: 5),
        menuWidget(state),
      ],
    );
  }

  Widget menuWidget(AudioState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(onPressed: () {}, icon: Icon(Icons.timelapse)),
        AudioBookmarkButton(
          file: AudioStateController.instance.getAudioFileById(
            state.currentSong!.id,
          )!,
        ),
        IconButton(onPressed: () {}, icon: Icon(Icons.list)),
      ],
    );
  }

  Widget marqueeWidget(String title) {
    return StreamBuilder(
      stream: AudioStateController.instance.stateStream,
      builder: (context, asyncSnapshot) {
        if (!AudioStateController.instance.state.isPlaying) {
          return Center(
            child: Text(
              title,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
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
      },
    );
  }
}

class CoverHeaderBox extends StatelessWidget {
  final String coverPath;
  final Widget coverWiget;
  const CoverHeaderBox({
    super.key,
    required this.coverPath,
    required this.coverWiget,
  });

  // late Future<PaletteGeneratorMaster> paletteFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PaletteGeneratorMaster.fromImageProvider(
        FileImage(File(coverPath)),
      ),
      builder: (context, snapshot) {
        final generator = snapshot.data;

        return Container(
          width: 280, // Music App တွေရဲ့ Standard ပုံအရွယ်အစား
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: boxShadow(generator),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: coverWiget, // သင့်ရဲ့ ရုပ်ပုံ Widget
          ),
        );
      },
    );
  }

  List<BoxShadow>? boxShadow(PaletteGeneratorMaster? generator) {
    if (generator == null) return null;
    final dominantColor = generator.dominantColor?.color ?? Colors.black;

    // final vibrantColor = generator.vibrantColor?.color ?? dominantColor;
    return [
      BoxShadow(
        color: dominantColor.withValues(alpha: 0.55),
        blurRadius: 30,
        spreadRadius: 3,
      ),

      // အောက်ဘက် shadow
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.4),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ];
  }
}
