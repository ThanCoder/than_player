import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';

enum ListStyleType {
  list,
  grid;

  static ListStyleType fromValue(String val) {
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

class ListStyleProvider extends StatefulWidget {
  const ListStyleProvider({super.key});

  @override
  State<ListStyleProvider> createState() => _ListStyleProviderState();

  static final valueNotifier = ValueNotifier<ListStyleType>(.list);
  static void init() {
    final val = ListStyleType.fromValue(
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

class _ListStyleProviderState extends State<ListStyleProvider> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ListStyleProvider.init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ListStyleProvider.valueNotifier,
      builder: (context, value, child) {
        return IconButton(
          onPressed: () {
            var currentIndex = value.currentIndex;
            currentIndex = (currentIndex + 1) % ListStyleType.values.length;
            ListStyleProvider.valueNotifier.value =
                ListStyleType.values[currentIndex];
            ListStyleProvider.save();
          },
          icon: Icon(value.iconData),
        );
      },
    );
  }
}
