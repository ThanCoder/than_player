import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_player/core/models/audio_file.dart';
import 'package:than_player/core/state/audio/audio_state_controller.dart';
import 'package:than_player/extensions/build_context_exts.dart';
import 'package:than_player/main/components/audio_list_item.dart';
import 'package:than_player/main/home/audio/audio_edit_cover_page.dart';

class AudioSliverList extends StatefulWidget {
  final List<AudioFile> list;
  final void Function(AudioFile file)? onClicked;
  const AudioSliverList({super.key, required this.list, this.onClicked});

  @override
  State<AudioSliverList> createState() => _AudioSliverListState();
}

class _AudioSliverListState extends State<AudioSliverList> {
  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.list.length,
      itemBuilder: (context, index) => listItem(widget.list[index]),
    );
  }

  Widget listItem(AudioFile file) {
    return AudioListItem(
      file: file,
      onClicked: (file) {
        if (widget.onClicked != null) {
          widget.onClicked!(file);
          return;
        }
        AudioStateController.instance.playTrack(file);
      },
      onMenuClicked: showAudioMenu,
    );
  }

  void showAudioMenu(AudioFile file) {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit Cover'),
          onTap: () async {
            context.pop();
            await context.push(
              builder: (mainContext) => AudioEditCoverPage(file: file),
            );
            setState(() {});
          },
        ),
        ListTile(
          leading: Icon(Icons.open_in_browser),
          title: Text('Open External'),
          onTap: () {
            context.pop();
            ThanPkg.platform.launch(file.path);
          },
        ),
      ],
    );
  }
}
