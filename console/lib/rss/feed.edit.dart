import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;
import './rss.pb.dart';

class Edit extends StatelessWidget {
  final Feed current;
  final Function(Feed)? onChange;
  final EdgeInsetsGeometry? padding;
  Edit({super.key, Feed? current, this.onChange, this.padding})
    : current = current ?? (Feed.create()..autodownload = false);

  @override
  Widget build(BuildContext context) {
    final theming = Theme.of(context);

    return Container(
      padding: padding,
      color: theming.scaffoldBackgroundColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 128, minWidth: 128),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            forms.Field(
              label: Text("description"),
              input: TextFormField(
                initialValue: current.description,
                onChanged: (v) => onChange?.call(current..description = v),
              ),
            ),
            forms.Field(
              label: Text("url"),
              input: TextFormField(
                initialValue: current.url,
                onChanged: (v) => onChange?.call(current..url = v),
              ),
            ),
            forms.Field(
              label: Text("encryption seed"),
              input: Tooltip(
                message:
                    "seed used to generate consistent encryption across users for a given torrent",
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: TextFormField(
                      decoration: InputDecoration(hintText: current.encryptionSeed),
                      initialValue: current.encryptionSeed,
                      onChanged:
                          (v) => onChange?.call(current..encryptionSeed = v),
                    )),
                  ],
                ),
              ),
            ),
            forms.Field(
              label: Text("autodownload"),
              input: forms.Checkbox(
                value: current.autodownload,
                onChanged: (v) {
                  onChange?.call(
                    current..autodownload = (v ?? current.autodownload),
                  );
                },
              ),
            ),
            forms.Field(
              label: Text("autoarchive"),
              input: forms.Checkbox(
                value: current.autoarchive,
                onChanged: (v) {
                  onChange?.call(
                    current..autoarchive = (v ?? current.autoarchive),
                  );
                },
              ),
            ),
            forms.Field(
              label: Text("contribution"),
              input: Tooltip(
                message:
                    "support this open source community by providing distribution when autodownload is enabled, and financially when autoarchive is enabled",
                child: forms.Checkbox(value: current.contributing),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
