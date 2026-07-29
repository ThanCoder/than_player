import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/main/home/audio/audio_home_page.dart';
import 'package:than_player/main/home/audio/playing_audio_widget.dart';
import 'package:than_player/main/home/bookmark/bookmark_page.dart';
import 'package:than_player/main/home/more_page.dart';
import 'package:than_player/main/home/video/video_home_page.dart';

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

          Positioned(bottom: 0, left: 0, right: 0, child: PlayingAudioWidget()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: Colors.blue,
        unselectedItemColor: context.brightness == .dark
            ? Colors.white
            : Colors.black,
        onTap: (value) {
          setState(() {
            index = value;
          });
          if (index == 3) return;
          CFBStore.getInstance.put('home_screen_index', index);
          CFBStore.getInstance.writeAll();
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Music'),
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
    );
  }
}
