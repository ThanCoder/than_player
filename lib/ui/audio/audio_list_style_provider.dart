import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';

enum AudioListStyleType {
  list,
  grid;

  static AudioListStyleType fromValue(String val) {
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

class AudioListStyleProvider extends StatefulWidget {
  const AudioListStyleProvider({super.key});

  @override
  State<AudioListStyleProvider> createState() => _AudioListStyleProviderState();

  static final valueNotifier = ValueNotifier<AudioListStyleType>(.list);
  static void init() {
    final val = AudioListStyleType.fromValue(
      CFBStore.getInstance.getString('audio-list-style-provider'),
    );
    if (valueNotifier.value != val) {
      valueNotifier.value = val;
    }
  }

  static void save() {
    CFBStore.getInstance.put(
      'audio-list-style-provider',
      valueNotifier.value.name,
    );
    CFBStore.getInstance.writeAll();
  }
}

class _AudioListStyleProviderState extends State<AudioListStyleProvider> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioListStyleProvider.init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AudioListStyleProvider.valueNotifier,
      builder: (context, value, child) {
        return IconButton(
          onPressed: () {
            var currentIndex = value.currentIndex;
            currentIndex =
                (currentIndex + 1) % AudioListStyleType.values.length;
            AudioListStyleProvider.valueNotifier.value =
                AudioListStyleType.values[currentIndex];
            AudioListStyleProvider.save();
          },
          icon: Icon(value.iconData),
        );
      },
    );
  }
}
