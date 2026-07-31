import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/audio_bookmark/audio_bookmark_controller.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/core/utils/utils.dart';
import 'package:than_player/main/home/audio/audio_cache_list_controller.dart';
import 'package:than_player/main/main_app.dart';
import 'package:than_player/video_bookmark/video_bookmark_controller.dart';
import 'package:than_player/video_config/video_config_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Utils.instance.init();

  await TWidgets.instance.init(
    defaultImageAssetsPath: 'assets/images/logos/logo.png',
  );

  JustAudioMediaKit.ensureInitialized(linux: true, android: true);
  await AudioStateController.instance.init();

  await CFBStore.getInstance.open(
    Utils.instance.getConfigPath('config.store.cfb'),
  );

  await AudioCacheListController.instance.init(
    Utils.instance.getConfigPath('audio-cache-list.cbf'),
  );

  await AudioBookmarkController.instance.init(
    Utils.instance.getExternalConfigPath('audio-bookmark-id-list.cbf'),
  );
  await VideoBookmarkController.instance.init(
    Utils.instance.getExternalConfigPath('video-bookmark-id-list.cbf'),
  );
  await VideoConfigServices.instance.init(
    Utils.instance.getConfigPath('video-config.cfb'),
  );

  runApp(const MainApp());
}
