import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_taglib/flutter_taglib.dart';
import 'package:than_player/core/utils/utils.dart';

class AudioMeta {
  final String path;
  AudioMeta(this.path);

  String? album;
  String? title;
  String? artist;
  String? comment;
  String? coverMimeType;
  String? bitrateMode;
  String? genre;
  bool hasCover = false;
  Duration? duration;

  void openMeta() {
    final file = TagLibFile.open(path);
    if (file != null) {
      if (file.title.isNotEmpty) {
        title = file.title;
      }

      if (file.album.isNotEmpty) {
        album = file.album;
      }
      if (file.artist.isNotEmpty) {
        artist = file.artist;
      }
      if (file.bitrateMode.isNotEmpty) {
        bitrateMode = file.bitrateMode;
      }
      if (file.comment.isNotEmpty) {
        comment = file.comment;
      }
      if (file.genre.isNotEmpty) {
        genre = file.genre;
      }
      coverMimeType = file.coverMimeType;
      hasCover = file.hasCover;
      duration = file.duration;
      // album = file.sampleRate;
      file.close();
    }
  }

  String get formatDuration {
    if (duration == null) return '00:00';
    final mins = duration!.inMinutes;
    final secs = duration!.inSeconds % 60;

    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<Uint8List?> readImageAsync() async {
    final file = await TagLibFile.openAsync(path);
    Uint8List? coverData;
    if (file != null) {
      coverData = file.coverData;
      file.close();
    }
    return coverData;
  }

  Future<String> readImageCache(String cacheName) async {
    final cacheFile = File(Utils.instance.getCachePath(cacheName));
    if (!cacheFile.existsSync()) {
      final bytes = await readImageAsync();
      if (bytes == null) return cacheFile.path;
      await cacheFile.writeAsBytes(bytes);
    }
    return cacheFile.path;
  }
}
