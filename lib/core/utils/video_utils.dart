import 'dart:io';

import 'package:media_kit/media_kit.dart';

class VideoUtils {
  static Future<void> genVideoThumbnail(
    String videoPath,
    File outFile, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    final player = Player();

    await player.open(Media(videoPath), play: false);
    await player.seek(duration);

    final data = await player.screenshot();
    if (data != null && !outFile.existsSync()) {
      await outFile.writeAsBytes(data);
    }

    await player.dispose();
  }
}
