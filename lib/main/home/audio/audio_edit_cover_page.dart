import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_audiotag/than_audiotag.dart';
import 'package:than_player/core/models/audio_file.dart';

class AudioEditCoverPage extends StatefulWidget {
  final AudioFile file;
  const AudioEditCoverPage({super.key, required this.file});

  @override
  State<AudioEditCoverPage> createState() => _AudioEditCoverPageState();
}

class _AudioEditCoverPageState extends State<AudioEditCoverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          spacing: 5,
          children: [
            Text('Choosr Cover Image'),
            TCoverChooser(
              coverPath: widget.file.cacheCoverPath,
              onChanged: setCover,
            ),
            if (File(widget.file.cacheCoverPath).existsSync())
              TextButton(
                onPressed: () {
                  showTConfirmDialog(
                    context,
                    contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
                    onSubmit: deleteCover,
                  );
                },
                child: Text(
                  "Delete Cover Image",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void deleteCover() async {
    try {
      final imageFile = File(widget.file.cacheCoverPath);
      final f = ThanAudioTag.open(widget.file.path);
      if (f.cover != null) {
        f.removeCover();
        await imageFile.delete();
        if (!mounted) return;
        showTSnackBar(context, 'Cover Deleted');
      }
      f.close();

      // final tagFile = await TagLibFile.openAsync(
      //   widget.file.path,
      //   writeAccess: true,
      // );
      // if (!imageFile.existsSync() || tagFile == null) return;

      // tagFile.setCover(data: null);

      // if (tagFile.save()) {
      //   await imageFile.delete();
      //   if (!mounted) return;
      //   showTSnackBar(context, 'Cover Deleted');
      // }
      // tagFile.close();
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  void setCover() async {
    try {
      final imageFile = File(widget.file.cacheCoverPath);
      final f = ThanAudioTag.open(widget.file.path);
      f.writeCover(await imageFile.readAsBytes());
      if (!mounted) return;
      showTSnackBar(context, 'Cover Updated');
      f.close();
      setState(() {});

      // final tagFile = await TagLibFile.openAsync(
      //   widget.file.path,
      //   writeAccess: true,
      // );
      // if (!imageFile.existsSync() || tagFile == null) return;

      // tagFile.setCover(data: await imageFile.readAsBytes());

      // if (tagFile.save()) {
      //   if (!mounted) return;
      //   showTSnackBar(context, 'Cover Updated');
      // }
      // tagFile.close();
      // setState(() {});
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }
}
