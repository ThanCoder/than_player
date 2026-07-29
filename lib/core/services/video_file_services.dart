import 'dart:io';

import 'package:than_player/core/models/video_file.dart';

class VideoFileServices {
  static final VideoFileServices instance = VideoFileServices._();
  VideoFileServices._();

  /// File ကို Delete လုပ်ခြင်း (Associated Cache ပါဖျက်မည်)
  Future<bool> deleteVideo(VideoFile file) async {
    try {
      final videoIoFile = File(file.path);
      if (await videoIoFile.exists()) {
        await videoIoFile.delete();
      }

      // Associated Cache Cover Image ကိုပါ တစ်ပါတည်း ဖျက်ပေးရန်
      final cacheIoFile = File(file.cachCoverPath);
      if (await cacheIoFile.exists()) {
        await cacheIoFile.delete();
      }

      return true;
    } catch (e) {
      // Logging error
      return false;
    }
  }

  /// File ကို Rename လုပ်ခြင်း
  Future<VideoFile?> renameVideo(VideoFile file, String newName) async {
    try {
      final videoIoFile = File(file.path);
      if (!await videoIoFile.exists()) return null;

      final directory = videoIoFile.parent.path;
      final newPath = '$directory/$newName.';

      final renamedFile = await videoIoFile.rename(newPath);

      // Model အသစ်ပြန်ထုတ်ပေးခြင်း
      return VideoFile(
        id: file.id,
        name: newName,
        path: renamedFile.path,
        dirname: file.dirname,
        date: file.date,
        size: file.size,
        duration: file.duration,
      );
    } catch (e) {
      return null;
    }
  }
}
