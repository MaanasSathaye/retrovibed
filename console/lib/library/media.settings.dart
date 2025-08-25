import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/authn.dart' as authn;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/uuidx.dart' as uuidx;
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
  bool _dirty = false;
  media.Media _modified;

  _MediaSettingsState(this._modified);

  @override
  void dispose() {
    if (_dirty) {
      widget.onChange(
        media.media
            .update(
              _modified.id,
              _modified,
              options: [authn.Authenticated.devicebearer(context)],
            )
            .then((v) => v.media),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theming = Theme.of(context);
    final themex = ds.Defaults.of(context);
    return SelectionArea(
      child: Container(
        padding: themex.padding,
        color: theming.scaffoldBackgroundColor,
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
                    _dirty = true;
                    _modified = v;
                  });
                });
              },
            ),
            if (!uuidx.isMinMax(uuidx.fromString(_modified.torrentId))) ds.Accordion(
              expanded: true,
              description: Text("source details"),
              content: media.DownloadDisplay.fromID(_modified.torrentId),
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
