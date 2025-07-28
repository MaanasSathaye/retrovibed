import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/authn.dart' as authn;
import 'package:retrovibed/media.dart' as media;
import './known.media.dropdown.dart';
import './metadata.edit.dart';

class MediaSettings extends StatefulWidget {
  final media.Media current;
  final void Function(Future<media.Media> pending) onChange;

  const MediaSettings({
    super.key,
    required this.current,
    required this.onChange,
  });

  @override
  State<MediaSettings> createState() => _MediaSettingsState(current);
}

class _MediaSettingsState extends State<MediaSettings> {
  media.Media _modified;

  _MediaSettingsState(this._modified);

  @override
  void dispose() {
    widget.onChange(
      media.media
          .update(
            _modified.id,
            _modified,
            options: [authn.Authenticated.devicebearer(context)],
          )
          .then((v) => v.media),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themex = ds.Defaults.of(context);
    return SelectionArea(
      child: Container(
        padding: themex.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MediaEdit(
              current: _modified,
              padding: themex.padding,
              onChange: (Future<media.Media> p) {
                p.then((v) {
                  setState(() {
                    _modified = v;
                  });
                });
              },
            ),
            ds.Accordion(
              expanded: true,
              description: Text("metadata"),
              content: KnownMediaDropdown(
                current: _modified.knownMediaId,
                onChange: (known) {
                  widget.onChange(
                    media.discovered
                        .metadatasync(
                          _modified.torrentId,
                          _modified..knownMediaId = known.id,
                          options: [authn.Authenticated.devicebearer(context)],
                        )
                        .then((v) => v.media),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
