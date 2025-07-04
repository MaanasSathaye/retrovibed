import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/mimex.dart' as mimex;
class SearchTuning extends StatelessWidget {
  final media.MediaSearchRequest current;
  final void Function(media.MediaSearchRequest r) onChange;
  SearchTuning(this.current, {super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final defaults = ds.Defaults.of(context);

    return forms.Container(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Row(
            mainAxisSize: MainAxisSize.max,
            spacing: defaults.spacing ?? 10.0,
            children: [
              TextButton(
                child: Text("media"),
                onPressed: mimex.checksumfor(mimex.movie) == mimex.checksum([]) ? () => onChange(current) : null,
              ),
              TextButton(
                child: Text("music"),
                onPressed: () => onChange(current),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }
}
