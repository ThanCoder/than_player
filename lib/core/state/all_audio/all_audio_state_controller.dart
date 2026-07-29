import 'dart:async';

import 'package:cfb_store/cfb_store.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/all_audio/all_audio_state.dart';
import 'package:than_player/core/utils/audio_scanner.dart';
import 'package:than_player/partials/sort_provider.dart';

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

  Future<void> scanAudioListFromStorage() async {
    try {
      //**************Sort****************** */
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

      final list = await AudioScanner().scan();
      _state = _state.copyWith(isLoading: false, list: list);
      sort();
      _controller.add(_state);
    } catch (e) {
      _state = _state.copyWith(error: e.toString(), isLoading: false);
      _controller.add(_state);
    }
  }

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
}
