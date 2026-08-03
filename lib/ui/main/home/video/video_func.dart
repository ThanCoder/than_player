import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/models/video_file.dart';
import 'package:than_player/core/state/video/video_state_controller.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/ui/main/home/video/video_content_screen.dart';
import 'package:than_player/ui/video/video_config/video_config.dart';
import 'package:than_player/ui/video/video_config/video_config_services.dart';

Future<void> goVideoContentScreen(BuildContext context, VideoFile file) async {
  final config = await context.push<VideoConfig>(
    builder: (mainContext) => VideoContentScreen(
      file: file,
      currentPositionInMiliseconds: VideoConfigServices.instance
          .getCurrentPosition(file.id),
    ),
  );
  if (config != null) {
    await VideoConfigServices.instance.setConfig(file.id, config);
  }
}

void showVideoContextItemMenu(BuildContext context, VideoFile file) {
  showTMenuBottomSheet(
    context,
    minHeight: 180,
    children: [
      ListTile(
        leading: Icon(Icons.edit_document),
        title: Text('Rename'),
        onTap: () {
          final parts = file.name.split('.');
          parts.removeLast();
          context.pop();
          showTReanmeDialog(
            context,
            text: parts.join('.'),
            isSelectAll: true,
            autofocus: true,
            submitText: 'Rename',
            onSubmit: (text) {
              final newName = '$text.${file.name.extName}';
              VideoStateController.instance.renameVideo(file, newName);
            },
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.delete, color: Colors.red),
        title: Text('Delete'),
        onTap: () {
          context.pop();
          showTConfirmDialog(
            context,
            contentText: '`${file.name}`\nဖျက်ချင်တာသေချာပြီလား',
            cancelText: 'No',
            submitText: 'Yes',
            onSubmit: () {
              VideoStateController.instance.deleteVideo(file);
              // VideoStateController.instance.removeVideoState(file);
            },
          );
        },
      ),
    ],
  );
}
