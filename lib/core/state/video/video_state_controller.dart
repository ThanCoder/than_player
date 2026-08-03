import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/services/video_file_services.dart';
import 'package:than_player/core/state/video/video_cache_list_controller.dart';
import 'package:than_player/core/state/video/video_state.dart';
import 'package:than_player/core/state/video/video_state_events.dart';
import 'package:than_player/core/utils/video_scanner.dart';
import 'package:than_player/ui/partials/sort_provider.dart';

class VideoStateController {
  static VideoStateController instance = VideoStateController._();
  VideoStateController._();
  factory VideoStateController() => instance;

  final _eventController = StreamController<VideoStateEvent>.broadcast();
  Stream<VideoStateEvent> get eventStream => _eventController.stream;

  final _controller = StreamController<VideoState>.broadcast();
  Stream<VideoState> get stateStream => _controller.stream;
  VideoState _state = VideoState.empty();
  VideoState get state => _state;
  final List<SortItem> sortList = [
    SortItem.nameSortItem,
    SortItem.dateSortItem,
    SortItem.sizeSortItem,
  ];

  //********************Scan Video Files******************** */
  final _scanner = VideoScanner();
  Future<void> scanList({bool usedCache = true}) async {
    try {
      //**************Sort****************** */
      SortItem sortItem = sortList[1];
      final recentSortId = CFBStore.getInstance.getInt(
        'video-file-sort-id',
        sortItem.id,
      );
      final recentSortTrue = CFBStore.getInstance.getBool(
        'video-file-sort-true',
      );
      if (recentSortId != sortItem.id) {
        final index = sortList.indexWhere((e) => e.id == recentSortId);
        if (index != -1) {
          sortItem = sortList[index].copyWith(isTrue: recentSortTrue);
        }
      }
      _state = _state.copyWith(
        error: '',
        isLoading: true,
        list: [],
        sortItem: sortItem,
      );
      _controller.add(_state);
      //**************Sort End****************** */

      // used cache
      if (usedCache) {
        var list = _state.list;
        VideoCacheListController.instance.setList(_state.list);
        if (_state.list.isEmpty) {
          list = await _scanner.scan();
          VideoCacheListController.instance.addCacheList(list);
        }
        _state = _state.copyWith(isLoading: false, list: list);
        sort(_state.list);
        _controller.add(_state);
        await scanAudioListFromBackgroundStorage();
      }
      // no cache
      else {
        final list = await _scanner.scan();
        final folderNames = <String>{};
        for (var file in list) {
          folderNames.add(file.dirname);
        }
        _state = _state.copyWith(
          isLoading: false,
          list: list,
          folderNames: folderNames,
        );
        sort(_state.list);
        _controller.add(_state);
      }
    } catch (e) {
      _state = _state.copyWith(error: e.toString(), isLoading: false);
      _controller.add(_state);
    }
  }

  Future<void> scanAudioListFromBackgroundStorage() async {
    final list = await _scanner.scan();
    debugPrint('[background fetched]: len ${list.length}');
    if (list.length != state.list.length) {
      _state = _state.copyWith(list: list);
      VideoCacheListController.instance.addCacheList(list);
      sort(_state.list);
      _controller.add(_state);
    }
  }

  void setListWithDirname(String dirname, List<VideoFile> files) {
    //dirname တူတာ အကုန်ဖျက်
    _state.list.removeWhere((e) => e.dirname == dirname);
    _state.list.addAll(files);
    sort(_state.list);
    _controller.add(_state);
  }

  //********************Sort******************** */
  void sort(List<VideoFile> list) {
    if (_state.sortItem.id == SortItem.nameSortItem.id) {
      list.sortName(isA2Z: _state.sortItem.isTrue);
    } else if (_state.sortItem.id == SortItem.dateSortItem.id) {
      list.sortDate(isNewest: _state.sortItem.isTrue);
    } else if (_state.sortItem.id == SortItem.sizeSortItem.id) {
      list.sortSize(smToBig: _state.sortItem.isTrue);
    }
  }

  void setSort(SortItem item) {
    CFBStore.getInstance.put('video-file-sort-id', item.id);
    CFBStore.getInstance.put('video-file-sort-true', item.isTrue);
    CFBStore.getInstance.writeAll();

    _state = _state.copyWith(sortItem: item);
    sort(_state.list);
    _controller.add(_state);
  }

  //********************Video File******************** */
  /// ### add -> State.
  void addVideo(VideoFile newFile, {String? eventKey}) {
    _eventController.add(VideoStateAddEvent(newFile, eventKey: eventKey));
    _state.list.add(newFile);
    _controller.add(_state);
  }

  /// ### rename -> State.
  void renameVideoState(VideoFile newFile, {String? eventKey}) {
    _eventController.add(VideoStateRenameEvent(newFile, eventKey: eventKey));
    final index = state.list.indexWhere((e) => e.id == newFile.id);
    if (index == -1) return;
    _state.list[index] = newFile;
    _controller.add(_state);
  }

  /// ### remove -> State.
  void removeVideoState(VideoFile file, {String? eventKey}) {
    _eventController.add(VideoStateRemoveEvent(file, eventKey: eventKey));
    final index = state.list.indexWhere(
      (e) => e.id == file.id && e.name == file.name,
    );
    if (index == -1) return;
    _state.list.removeAt(index);
    _controller.add(_state);
  }

  //********************Video File Services******************** */
  final VideoFileServices _fileService = VideoFileServices.instance;

  /// ### delete -> State And Disk File!.
  Future<void> deleteVideo(VideoFile file) async {
    final isSuccess = await _fileService.deleteVideo(file);

    if (isSuccess) {
      // Memory ထဲက List ထဲမှ ဖယ်ထုတ်ပြီး State အသစ်တင်ပေးခြင်း
      final updatedList = List<VideoFile>.from(_state.list)
        ..removeWhere((e) => e.id == file.id);

      _state = _state.copyWith(list: updatedList);
      _controller.add(_state);
      _eventController.add(VideoStateRemoveEvent(file));
    } else {
      _state = _state.copyWith(error: 'Failed to delete file');
      _controller.add(_state);
    }
  }

  /// ### rename -> State And Disk File!.
  Future<void> renameVideo(VideoFile file, String newName) async {
    final updatedVideo = await _fileService.renameVideo(file, newName);

    if (updatedVideo != null) {
      final index = _state.list.indexWhere((e) => e.id == file.id);
      if (index != -1) {
        final updatedList = List<VideoFile>.from(_state.list);
        updatedList[index] = updatedVideo;

        _state = _state.copyWith(list: updatedList);
        sort(_state.list); // Sort ပြန်စီပေးရန် (လိုအပ်ပါက)
        _controller.add(_state);
        _eventController.add(VideoStateRenameEvent(file));
      }
    } else {
      _state = _state.copyWith(error: 'Failed to rename file');
      _controller.add(_state);
    }
  }
}
