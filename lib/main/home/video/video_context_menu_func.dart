import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state_controller.dart';
import 'package:than_player/extensions/build_context_exts.dart';

void showVideoContextItemMenu(BuildContext context, VideoFile file) {
  showTMenuBottomSheet(
    context,
    minHeight: 180,
    children: [
      ListTile(
        leading: Icon(Icons.edit_document),
        title: Text('Rename'),
        onTap: () {
          context.pop();
          showTReanmeDialog(
            context,
            text: file.name.onlyName,
            isSelectAll: true,
            submitText: 'Rename',
            onSubmit: (text) {
              final newName = '$text.${file.name.extName}';
              VideoStateController.instance.renameVideo(file, newName);
            },
          );
        },
      ),
    ],
  );
}
