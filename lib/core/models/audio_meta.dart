// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_taglib/flutter_taglib.dart';
import 'package:mime/mime.dart';

import 'package:than_player/core/utils/utils.dart';

class AudioMeta {
  final String path;
  AudioMeta(
    this.path, {
    this.album = '',
    this.artist = '',
    this.bitrate = 0,
    this.bitrateMode = '',
    this.comment = '',
    this.coverMimeType = '',
    this.duration = .zero,
    this.format = '',
    this.genre = '',
    this.hasCover = false,
    this.sampleRate = 0,
    this.title = '',
  });

  String album;
  String title;
  String artist;
  String comment;
  String coverMimeType;
  String bitrateMode;
  String genre;
  bool hasCover;
  Duration duration;
  String format;
  int bitrate;
  int sampleRate;

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'album': album,
      'title': title,
      'artist': artist,
      'comment': comment,
      'coverMimeType': coverMimeType,
      'genre': genre,
      'bitrateMode': bitrateMode,
      'hasCover': hasCover,
      'duration': duration.inMilliseconds,
      'format': format,
      'bitrate': bitrate,
      'sampleRate': sampleRate,
    };
  }

  factory AudioMeta.fromMap(Map<String, dynamic> map) {
    return AudioMeta(
      map['path'],
      album: map['album'],
      title: map['title'],
      artist: map['artist'],
      comment: map['comment'],
      coverMimeType: map['coverMimeType'],
      bitrateMode: map['bitrateMode'],
      genre: map['genre'],
      hasCover: map['hasCover'],
      duration: Duration(milliseconds: map['duration'] ?? 0),
      format: map['format'],
      bitrate: map['bitrate'],
      sampleRate: map['sampleRate'],
    );
  }

  Future<void> getDurationInAndroid() async {
    if (Platform.isAndroid) {}
  }

  void openMeta() {
    final mm = lookupMimeType(path);
    format = mm ?? '';
    final file = TagLibFile.open(path);
    if (file == null) {
      debugPrint('[Dev:AudioMeta:openMeta]: `TagLibFile.open` Error');
      return;
    }
    if (file.title.isNotEmpty) {
      title = file.title;
    }
    bitrate = file.audioInfo.bitrate;
    sampleRate = file.audioInfo.sampleRate;

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
    coverMimeType = file.coverMimeType ?? '';
    hasCover = file.hasCover;
    if (Platform.isLinux) {
      duration = file.duration;
    }
    if (Platform.isAndroid) {
      // https://pub.dev/packages/flutter_taglib
      //bugs ဖြစ်နေတာ
      if (file.duration.inSeconds == 0 && file.duration.inMilliseconds > 0) {
        duration = Duration(seconds: file.duration.inMilliseconds);
      } else {
        duration = file.duration;
      }
    }
    file.close();
  }

  String get formatDuration {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;

    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get formatLabel {
    return path.extName.toUpperCase();
  }

  String get bitrateLabel {
    return '$bitrate kb/s';
  }

  String get sampleRateLabel {
    return '${sampleRate / 1000} kHz';
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

  @override
  String toString() => 'AudioMeta(path: $path)';
}
