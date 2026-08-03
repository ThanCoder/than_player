import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';

enum VideoListStyleType {
  list,
  grid;

  static VideoListStyleType fromValue(String val) {
    return values.firstWhere((e) => e.name == val, orElse: () => list);
  }

  int get currentIndex {
    return values.indexWhere((e) => e == this);
  }

  IconData get iconData {
    if (this == grid) return Icons.grid_view_rounded;
    return Icons.list;
  }
}

class VideoListStyleProvider extends StatefulWidget {
  const VideoListStyleProvider({super.key});

  @override
  State<VideoListStyleProvider> createState() => _ListStyleProviderState();

  static final valueNotifier = ValueNotifier<VideoListStyleType>(.list);
  static void init() {
    final val = VideoListStyleType.fromValue(
      CFBStore.getInstance.getString('video-list-style-provider'),
    );
    if (valueNotifier.value != val) {
      valueNotifier.value = val;
    }
  }

  static void save() {
    CFBStore.getInstance.put(
      'video-list-style-provider',
      valueNotifier.value.name,
    );
    CFBStore.getInstance.writeAll();
  }
}

class _ListStyleProviderState extends State<VideoListStyleProvider> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VideoListStyleProvider.init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: VideoListStyleProvider.valueNotifier,
      builder: (context, value, child) {
        return IconButton(
          onPressed: () {
            var currentIndex = value.currentIndex;
            currentIndex =
                (currentIndex + 1) % VideoListStyleType.values.length;
            VideoListStyleProvider.valueNotifier.value =
                VideoListStyleType.values[currentIndex];
            VideoListStyleProvider.save();
          },
          icon: Icon(value.iconData),
        );
      },
    );
  }
}
