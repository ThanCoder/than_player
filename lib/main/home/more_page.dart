import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart' hide MaterialThemeProviderChooser;
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/core/utils/utils.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/partials/cache_manager.dart';
import 'package:than_player/partials/material_theme_provider.dart'
    show MaterialThemeProviderChooser;
import 'package:than_player/settings/audio_setting_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Than Player')),
      body: TScrollableColumn(
        children: [
          Card(child: MaterialThemeProviderChooser()),
          Card(
            child: ListTile(
              title: Text("Version: ${Utils.instance.packageInfo.version}"),
            ),
          ),
          CacheManagerListTile(cacheDirPath: Utils.instance.cachePath),
          Divider(),
          Card(
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text('Audio Setting'),
              onTap: () {
                context.push(builder: (mainContext) => AudioSettingPage());
              },
            ),
          ),
          if (kDebugMode)
            Card(
              child: ListTile(
                title: Text('Dispose Player'),
                onTap: () async {
                  await AudioStateController.instance.disposePlayerServices();
                  if (!context.mounted) return;
                  showTSnackBar(context, 'Player Services Closed');
                },
              ),
            ),
          Card(child: ListTile(title: Text("Developer: `ThanCoder`"))),
        ],
      ),
    );
  }
}
