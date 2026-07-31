import 'package:dart_core_extensions/dart_core_extensions.dart';

extension StrExts on String {
  String join(String name) {
    return PathBuf(this).join(name).path;
  }
}
