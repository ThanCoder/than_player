import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/services/video_file_services.dart';
import 'package:than_player/core/state/video/video_state.dart';
import 'package:than_player/core/utils/video_scanner.dart';
import 'package:than_player/partials/sort_provider.dart';

class VideoStateController {
  static VideoStateController instance = VideoStateController._();
  VideoStateController._();
  factory VideoStateController() => instance;

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
  Future<void> scanList() async {
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

      final list = await _scanner.scan();
      _state = _state.copyWith(isLoading: false, list: list);
      sort();
      _controller.add(_state);
    } catch (e) {
      _state = _state.copyWith(error: e.toString(), isLoading: false);
      _controller.add(_state);
    }
  }

  //********************Sort******************** */
  void sort() {
    if (_state.sortItem.id == SortItem.nameSortItem.id) {
      _state.list.sortName(isA2Z: _state.sortItem.isTrue);
    } else if (_state.sortItem.id == SortItem.dateSortItem.id) {
      _state.list.sortDate(isNewest: _state.sortItem.isTrue);
    } else if (_state.sortItem.id == SortItem.sizeSortItem.id) {
      _state.list.sortSize(smToBig: _state.sortItem.isTrue);
    }
  }

  void setSort(SortItem item) {
    CFBStore.getInstance.put('video-file-sort-id', item.id);
    CFBStore.getInstance.put('video-file-sort-true', item.isTrue);
    CFBStore.getInstance.writeAll();

    _state = _state.copyWith(sortItem: item);
    sort();
    _controller.add(_state);
  }

  //********************Video File Services******************** */
  final VideoFileServices _fileService = VideoFileServices.instance;

  Future<void> deleteVideo(VideoFile file) async {
    final isSuccess = await _fileService.deleteVideo(file);

    if (isSuccess) {
      // Memory ထဲက List ထဲမှ ဖယ်ထုတ်ပြီး State အသစ်တင်ပေးခြင်း
      final updatedList = List<VideoFile>.from(_state.list)
        ..removeWhere((e) => e.id == file.id);

      _state = _state.copyWith(list: updatedList);
      _controller.add(_state);
    } else {
      _state = _state.copyWith(error: 'Failed to delete file');
      _controller.add(_state);
    }
  }

  Future<void> renameVideo(VideoFile file, String newName) async {
    final updatedVideo = await _fileService.renameVideo(file, newName);

    if (updatedVideo != null) {
      final index = _state.list.indexWhere((e) => e.id == file.id);
      if (index != -1) {
        final updatedList = List<VideoFile>.from(_state.list);
        updatedList[index] = updatedVideo;

        _state = _state.copyWith(list: updatedList);
        sort(); // Sort ပြန်စီပေးရန် (လိုအပ်ပါက)
        _controller.add(_state);
      }
    } else {
      _state = _state.copyWith(error: 'Failed to rename file');
      _controller.add(_state);
    }
  }
}
