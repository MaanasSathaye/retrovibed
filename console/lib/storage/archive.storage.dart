import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/designkit.dart' as ds;

class ArchiveStorageSettings extends StatefulWidget {
  ArchiveStorageSettings({super.key});

  @override
  State<ArchiveStorageSettings> createState() => _ArchiveStorageSettings();
}

class _ArchiveStorageSettings extends State<ArchiveStorageSettings> {
  int _maximum = 0 * ds.bytesx.GiB;

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return forms.Container(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          forms.Field(
            label: Text("maximum"),
            input: Tooltip(
              message: "maximum usage allowed above your plan's included storage",
              child: ds.ByteWidget(
                value: 0,
                magnitude: ds.bytesx.GiB,
                onChange: (v) {
                  setState(() {
                    _maximum = v;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
