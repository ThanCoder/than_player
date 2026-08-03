// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:mime/mime.dart';
import 'package:than_audiotag/than_audiotag.dart';

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

  void openMeta(String cachePath) {
    final mm = lookupMimeType(path);
    format = mm ?? '';
    try {
      final file = ThanAudioTag.open(path);
      title = file.tag.title;
      album = file.tag.album;
      artist = file.tag.artist;
      comment = file.tag.comment;
      genre = file.tag.genre;
      // track = file.tag.track;
      // year = file.tag.year;
      duration = file.properties.durationAsDuration;
      bitrate = file.properties.bitrate;
      // channels = file.properties.channels;
      sampleRate = file.properties.sampleRate;
      if (file.cover != null) {
        coverMimeType = file.cover!.mimeType;
        // description = file.cover!.description;
        // pictureType = file.cover!.pictureType;
        final cacheFile = File(cachePath);
        if (!cacheFile.existsSync()) {
          cacheFile.writeAsBytesSync(file.cover!.data);
        }
      }

      file.close();
    } catch (e) {
      debugPrint('[Dev: AudioMeta:openMeta]: $e');
    }
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

  Future<String> readImageCache(String cacheName) async {
    final cacheFile = File(Utils.instance.getCachePath(cacheName));
    // if (!cacheFile.existsSync()) {
    //   final bytes = await readImageAsync();
    //   if (bytes == null) return cacheFile.path;
    //   await cacheFile.writeAsBytes(bytes);
    // }
    return cacheFile.path;
  }

  @override
  String toString() => 'AudioMeta(path: $path)';
}
