import 'package:flutter/material.dart';
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/mimex.dart' as mimex;
import 'package:retrovibed/designkit.dart' as ds;

class SearchMimetypeDropdown extends StatelessWidget {
  final media.MediaSearchRequest current;
  final void Function(media.MediaSearchRequest r) onChange;
  SearchMimetypeDropdown(this.current, {super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final themex = ds.Defaults.of(context);
    final mimetypes = mimex.checksum(current.mimetypes);

    return Material(
      color: Colors.transparent,
      child: DropdownButton(
        alignment: Alignment.bottomLeft,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        icon: const SizedBox(),
        padding: EdgeInsets.symmetric(horizontal: themex.spacing),
        value: mimetypes,
        underline: const SizedBox(),
        items: [
          DropdownMenuItem(
            child: Icon(Icons.movie_filter),
            value: mimex.checksumfor(mimex.movie),
          ),
          DropdownMenuItem(
            child: Icon(Icons.music_note),
            value: mimex.checksumfor(mimex.audio),
          ),
          DropdownMenuItem(
            child: Icon(Icons.file_open_rounded),
            value: mimex.checksumfor(mimex.binary),
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
    );
  }
}
