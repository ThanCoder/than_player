import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_player/core/utils/utils.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Than Player')),
      body: TScrollableColumn(
        children: [
          Card(
            child: ListTile(
              title: Text("Version: ${Utils.instance.packageInfo.version}"),
            ),
          ),
          Card(child: ListTile(title: Text("Developer: `ThanCoder`"))),
        ],
      ),
    );
  }
}
