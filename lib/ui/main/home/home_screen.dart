import 'dart:ui'; // ImageFilter အတွက် ပါရပါမည်
import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/ui/main/home/audio/audio_home_page.dart';
import 'package:than_player/ui/main/home/audio/playing_audio_widget.dart';
import 'package:than_player/ui/main/home/bookmark/bookmark_page.dart';
import 'package:than_player/ui/main/home/more_page.dart';
import 'package:than_player/ui/main/home/video/video_home_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = CFBStore.getInstance.getInt('home_screen_index');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 💡 အဓိကသော့ချက်: extendBody ကို true ထားပေးမှ Body က BottomBar ရဲ့ အနောက်အထိ သွားပြီး Blur ပေါ်မှာပါ
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: index,
              children: [
                AudioHomePage(isCurrentPage: index == 0),
                VideoHomePage(isCurrentPage: index == 1),
                BookmarkPage(isCurrentPage: index == 2),
                MorePage(key: UniqueKey()),
              ],
            ),
          ),

          // PlayingAudioWidget ကို BottomNavigationBar ရဲ့ အပေါ်မှာ တင်ထားနိုင်အောင် Bottom Offset ချိန်ပေးပါ
          Positioned(
            bottom:
                kBottomNavigationBarHeight, // BottomBar ရဲ့ အမြင့်အပေါ်မှာ ပေါ်စေရန်
            left: 0,
            right: 0,
            child: const PlayingAudioWidget(),
          ),
        ],
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Blur intensity
          child: Container(
            decoration: BoxDecoration(
              color: context.brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.3) // Dark mode မဲမဲမှန်ကြည်
                  : Colors.white.withValues(alpha: 0.4), // Light mode ဖြူဖြူမှန်ကြည်
              border: Border(
                top: BorderSide(
                  color: context.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              currentIndex: index,
              selectedItemColor: Colors.teal,
              unselectedItemColor: context.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.6),
              onTap: (value) {
                setState(() {
                  index = value;
                });
                if (index == 3) return;
                CFBStore.getInstance.put('home_screen_index', index);
                CFBStore.getInstance.writeAll();
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.music_note),
                  label: 'Music',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_collection),
                  label: 'Video',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_added),
                  label: 'Bookmark',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
