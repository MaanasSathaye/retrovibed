import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/designkit.dart' as ds;

class LocalStorageSettings extends StatefulWidget {
  LocalStorageSettings({super.key});

  @override
  State<LocalStorageSettings> createState() => _LocalStorageSettings();
}

class _LocalStorageSettings extends State<LocalStorageSettings> {
  // int _maximum = 0 * ds.bytesx.GiB;

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
              message:  "maximum disk usage allowed for this device",
              child: ds.ByteWidget(
                value: 256,
                magnitude: ds.bytesx.GiB,
                onChange: (v) {
                  // setState(() {
                  //   _maximum = v;
                  // });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
