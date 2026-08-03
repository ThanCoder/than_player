import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/all_audio/all_audio_state.dart';
import 'package:than_player/core/utils/audio_scanner.dart';
import 'package:than_player/core/state/all_audio/audio_cache_list_controller.dart';
import 'package:than_player/ui/audio/audio_blocklist/audio_blocklist_controller.dart';
import 'package:than_player/ui/partials/sort_provider.dart';

class AllAudioStateController {
  static AllAudioStateController instance = AllAudioStateController._();
  AllAudioStateController._();
  factory AllAudioStateController() => instance;

  final _controller = StreamController<AllAudioState>.broadcast();
  Stream<AllAudioState> get stateStream => _controller.stream;
  AllAudioState _state = .empty();
  AllAudioState get state => _state;

  final List<SortItem> sortList = [
    SortItem.nameSortItem,
    SortItem.dateSortItem,
    SortItem.sizeSortItem,
  ];
  final _scanner = AudioScanner();
  Future<void> scanAudioListFromStorageAndCache({bool usedCache = true}) async {
    try {
      SortItem sortItem = sortList[1];
      final recentSortId = CFBStore.getInstance.getInt(
        'audio-file-sort-id',
        sortItem.id,
      );
      final recentSortTrue = CFBStore.getInstance.getBool(
        'audio-file-sort-true',
      );
      if (recentSortId != sortItem.id) {
        final index = sortList.indexWhere((e) => e.id == recentSortId);
        if (index != -1) {
          sortItem = sortList[index].copyWith(isTrue: recentSortTrue);
        }
      }
      _state = _state.copyWith(isLoading: true, list: [], sortItem: sortItem);
      _controller.add(_state);

      if (usedCache) {
        var list = <AudioFile>[];
        AudioCacheListController.instance.setList(list);
        if (list.isEmpty) {
          list = await _scanner.scan();
          AudioCacheListController.instance.addCacheList(list);
        }
        _state = _state.copyWith(isLoading: false, list: list);
        sort();
        // filter blocklist
        filterBlockList(_state.list);
        _controller.add(_state);
        await scanAudioListFromBackgroundStorage();
      }
      // not cache
      else {
        _state = _state.copyWith(isLoading: true, list: [], sortItem: sortItem);
        final list = await _scanner.scan();
        AudioCacheListController.instance.addCacheList(list);
        _state = _state.copyWith(isLoading: false, list: list);
        sort();
        // filter blocklist
        filterBlockList(_state.list);
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
      _state = _state.copyWith(isLoading: false, list: list);
      AudioCacheListController.instance.addCacheList(list);
      sort();
      // filter blocklist
      filterBlockList(_state.list);
      _controller.add(_state);
    }
  }

  //**************block list****************** */
  void addBlockList(AudioFile file) {
    AudioBlocklistController.instance.add(file);
    filterBlockList(_state.list);

    _controller.add(_state);
  }

  void removeBlockList(AudioFile file) {
    AudioBlocklistController.instance.remove(file);

    _state.list.add(file);
    sort();
    _controller.add(_state);
  }

  void filterBlockList(List<AudioFile> files) {
    final blockedIds = AudioBlocklistController.instance.list
        .map((e) => e.id)
        .toSet();
    if (blockedIds.isEmpty) return;
    files.removeWhere((e) => blockedIds.contains(e.id));
  }

  //**************Sort****************** */
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
    CFBStore.getInstance.put('audio-file-sort-id', item.id);
    CFBStore.getInstance.put('audio-file-sort-true', item.isTrue);
    CFBStore.getInstance.writeAll();

    _state = _state.copyWith(sortItem: item);
    sort();
    _controller.add(_state);
  }

  int getSongIndexById(String id) {
    return state.list.indexWhere((e) => e.id == id);
  }
}
