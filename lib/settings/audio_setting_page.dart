import 'package:cfb_store/cfb_store.dart';
import 'package:flutter/material.dart';
import 'package:than_player/core/const_keys.dart';
import 'package:than_player/extensions/build_context_exts.dart';

class AudioSettingPage extends StatefulWidget {
  const AudioSettingPage({super.key});

  @override
  State<AudioSettingPage> createState() => _AudioSettingPageState();
  static final valueNotifier = ValueNotifier<int>(1);
}

class _AudioSettingPageState extends State<AudioSettingPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        AudioSettingPage.valueNotifier.value =
            AudioSettingPage.valueNotifier.value + 1;
        context.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Audio Setting')),
        body: ListView(
          children: [
            SwitchListTile.adaptive(
              title: Text('Audio Background Blur'),
              value: CFBStore.getInstance.getBool(
                audioBackgroundBlurColorKeyName,
              ),
              onChanged: (value) {
                CFBStore.getInstance.put(
                  audioBackgroundBlurColorKeyName,
                  value,
                );
                CFBStore.getInstance.writeAll();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
