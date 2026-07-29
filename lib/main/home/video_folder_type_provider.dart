import 'package:cfb_store/cfb_store.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:than_player/extensions/build_context_exts.dart';

enum VideoFolderType {
  allVideo,
  allFolders;

  static VideoFolderType fromValue(String val) {
    return values.firstWhere((e) => e.name == val, orElse: () => .allVideo);
  }
}

class VideoFolderTypeProvider extends StatefulWidget {
  const VideoFolderTypeProvider({super.key});

  @override
  State<VideoFolderTypeProvider> createState() =>
      _VideoFolderTypeProviderState();
  static final valueNotifier = ValueNotifier<VideoFolderType>(.allVideo);

  static void init() {
    final val = VideoFolderType.fromValue(
      CFBStore.getInstance.getString('video-folder-type'),
    );
    valueNotifier.value = val;
  }

  static void save(VideoFolderType value) {
    valueNotifier.value = value;
    CFBStore.getInstance.put('video-folder-type', valueNotifier.value.name);
    CFBStore.getInstance.writeAll();
  }
}

class _VideoFolderTypeProviderState extends State<VideoFolderTypeProvider> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: VideoFolderTypeProvider.valueNotifier,
      builder: (context, value, child) {
        return TextButton(
          onPressed: () async {
            await showMenu(
              context: context,
              positionBuilder: (context, constraints) => RelativeRect.fill,
              items: [
                PopupMenuItem(
                  child: CheckboxListTile.adaptive(
                    title: Text("All Videos"),
                    value: value == .allVideo,
                    onChanged: (value) {
                      VideoFolderTypeProvider.save(.allVideo);
                      context.pop();
                    },
                  ),
                ),
                PopupMenuItem(
                  enabled: true,
                  child: CheckboxListTile.adaptive(
                    title: Text("All Folders"),
                    value: value == .allFolders,
                    onChanged: (value) {
                      VideoFolderTypeProvider.save(.allFolders);
                      context.pop();
                    },
                  ),
                ),

                // PopupMenuItem(child: Text("All Folder Tree")),
              ],
            );
          },
          child: Text(value.name.toCaptalize),
        );
      },
    );
  }
}
