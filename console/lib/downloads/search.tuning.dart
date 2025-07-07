import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/mimex.dart' as mimex;

class queryparams {
  List<String> mimetypes = [];
  bool completed = false;
}

class SearchTuning extends StatelessWidget {
  final media.MediaSearchRequest current;
  final void Function(media.MediaSearchRequest r) onChange;
  SearchTuning(this.current, {super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final mimetypes = mimex.checksum(current.mimetypes);

    return forms.Container(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          forms.Field(
            input: DropdownButton(
              alignment: Alignment.topLeft,
              value: mimetypes,
              isExpanded: true,
              isDense: true,
              items: [
                DropdownMenuItem(
                  child: Text("all"),
                  value: mimex.checksumfor(mimex.binary),
                ),
                DropdownMenuItem(
                  child: Text("media"),
                  value: mimex.checksumfor(mimex.movie),
                ),
                DropdownMenuItem(
                  child: Text("audio"),
                  value: mimex.checksumfor(mimex.audio),
                ),
              ],
              onChanged: (v) {
                v = v ?? -1;
                if (v == mimex.checksumfor(mimex.movie)) {
                  current.mimetypes.clear();
                  current.mimetypes.addAll(mimex.of(mimex.movie));
                  onChange(current);
                  return;
                }

                if (v == mimex.checksumfor(mimex.audio)) {
                  current.mimetypes.clear();
                  current.mimetypes.addAll(mimex.of(mimex.audio));
                  onChange(current);
                  return;
                }

                current.mimetypes.clear();
                onChange(current);
              },
            ),
            label: Text("category"),
          ),
          forms.Field(
            input: forms.Checkbox(value: false),
            label: Text("completed"),
          ),
        ],
      ),
    );
  }
}
