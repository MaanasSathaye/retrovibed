import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/designkit.dart' as ds;

class SettingsLeech extends StatefulWidget {
  SettingsLeech({super.key});

  @override
  State<SettingsLeech> createState() => _EditView();
}

class _EditView extends State<SettingsLeech> {
  @override
  Widget build(BuildContext context) {
    return forms.Container(
      Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 32.0,
        children: [
          forms.Field(
            label: Text("download rate"),
            input: Tooltip(
              message: "maximum download rate allowed per second across all torrents, default (0) is unlimited",
              child: ds.ByteWidget(
                decoration: new InputDecoration(
                  hintText: "0",
                ),
                magnitude: ds.bytesx.KiB,
                // onChanged: (v) => widget.feed.description = v,
              ),
            ),
          ),
          forms.Field(
            label: Text("upload rate"),
            input: Tooltip(
              message: "maximum upload rate allowed per second across all torrents, default (0) is unlimited",
              child: ds.ByteWidget(
                decoration: new InputDecoration(
                  hintText: "0",
                ),
                magnitude: ds.bytesx.KiB,
                // onChanged: (v) => widget.feed.description = v,
              ),
            ),
          ),
          forms.Field(
            margin: EdgeInsets.only(top: 32.0),
            label: Text("peers"),
            input: TextFormField(
              decoration: new InputDecoration(
                hintText: "32",
                helperText:
                    "maximum number of peers allowed per torrent, default is 32",
              ),
              keyboardType: TextInputType.number,
              // onChanged: (v) => widget.feed.description = v,
            ),
          ),
        ],
      ),
    );
    // return ConstrainedBox(
    //   constraints: BoxConstraints(minHeight: 32, minWidth: 32),
    //   child: forms.Container(
    //     Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         forms.Field(
    //           label: Text("download"),
    //           input: ds.ByteWidget(
    //             decoration: new InputDecoration(
    //               hintText: "0",
    //               helperText:
    //                   "maximum download rate allowed per torrent (KiB/s), default (0) is unlimited",
    //             ),
    //             // onChanged: (v) => widget.feed.description = v,
    //           ),
    //         ),
    //         forms.Field(
    //           label: Text("upload"),
    //           input: ds.ByteWidget(
    //             decoration: new InputDecoration(
    //               hintText: "0",
    //               helperText:
    //                   "maximum upload rate allowed per torrent (KiB/s), default (0) is unlimited",
    //             ),
    //             // onChanged: (v) => widget.feed.description = v,
    //           ),
    //         ),

    //         forms.Field(
    //           label: Text("peers"),
    //           input: TextFormField(
    //             decoration: new InputDecoration(
    //               hintText: "32",
    //               helperText:
    //                   "maximum number of peers allowed per torrent, default is 32",
    //             ),
    //             keyboardType: TextInputType.number,
    //             // onChanged: (v) => widget.feed.description = v,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
