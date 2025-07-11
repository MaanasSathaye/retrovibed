import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'local.storage.dart';
import './archive.storage.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: [
          ds.Accordion(
            description: Row(children: [Text("cache"), Spacer(), Text("device hdd usage")]),
            content: LocalStorageSettings(),
          ),
          ds.Accordion(
            description: Row(children: [Text("archive"), Spacer(), Text("cloud storage usage")]),
            content: ArchiveStorageSettings(),
          ),
        ],
      );
  }
}
