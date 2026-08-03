import 'package:flutter/material.dart';
import 'package:than_player/ui/audio/audio_blocklist/audio_blocklist_controller.dart';
import 'package:than_player/ui/audio/audio_blocklist/audio_blocklist_view_page.dart';
import 'package:than_player/extensions/build_context_exts.dart';

class AudioBlocklistViewButton extends StatelessWidget {
  const AudioBlocklistViewButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (AudioBlocklistController.instance.list.isEmpty) {
      return SizedBox.shrink();
    }
    return SizedBox(
      width: 100,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          color: context.brightness == .dark
              ? const Color.fromARGB(255, 45, 45, 45)
              : const Color.fromARGB(255, 218, 218, 218),
          borderRadius: .circular(5),
        ),
        child: ClipRRect(
          borderRadius: .circular(5),
          child: BackdropFilter(
            filter: .blur(sigmaX: 10, sigmaY: 10),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(5),
              splashColor: Colors.teal.withValues(
                alpha: 0.2,
              ), // Click လုပ်ချိန် ထွက်လာမယ့် Ripple အရောင်
              highlightColor: Colors.teal.withValues(
                alpha: 0.1,
              ), // ဖိထားချိန် Background ပြောင်းသွားမယ့် အရောင်
              onTap: () {
                context.push(
                  builder: (mainContext) => AudioBlocklistViewPage(),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: AudioBlocklistController.instance.stream,
                  builder: (context, asyncSnapshot) {
                    return Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.teal),
                        Spacer(),
                        Text('Audio Blocked'),
                        Spacer(),

                        Text(
                          '${AudioBlocklistController.instance.list.length}',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
