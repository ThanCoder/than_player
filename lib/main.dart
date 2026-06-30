import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/core/utils/utils.dart';
import 'package:than_player/main/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Utils.instance.init();

  await TWidgets.instance.init(
    defaultImageAssetsPath: 'assets/images/logos/logo.png',
  );

  // or, if you want to manually configure enabled platforms instead:
  // make sure to include the required dependency in pubspec.yaml for
  // each enabled platform!
  JustAudioMediaKit.ensureInitialized(
    linux: true, // default: true  - dependency: media_kit_libs_linux
    android: true, // default: false - dependency: media_kit_libs_android_audio
  );
  await AudioStateController.instance.init();

  await CFBStoreBase.getInstance.open(
    Utils.instance.getConfigPath('config.store.cfb'),
  );

  runApp(const MainApp());
}
