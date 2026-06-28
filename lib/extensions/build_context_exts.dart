import 'package:flutter/material.dart';

extension BuildContextExts on BuildContext {
  Future<T?> push<T extends Object?>({
    required Widget Function(BuildContext mainContext) builder,
  }) async {
    return await Navigator.push<T>(this, MaterialPageRoute(builder: builder));
  }

  void pop<T extends Object?>([T? result]) async {
    Navigator.pop<T>(this, result);
  }

  Brightness get brightness {
    return Theme.brightnessOf(this);
  }
}
