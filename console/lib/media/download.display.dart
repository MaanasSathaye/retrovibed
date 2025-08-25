import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/typography.dart' as typography;
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/authn.dart' as authn;

import './api.dart' as api;

class DownloadDisplay extends StatelessWidget {
  final api.Download current;
  final Future<void> Function() onTap;
  const DownloadDisplay(
    this.current, {
    super.key,
    onTap,
  }) : onTap = onTap ?? ds.defaulttapv;

  static Widget fromID(String id) {
    return Builder(
      builder: (context) {
        return FutureBuilder<api.Download>(
          initialData: api.Download.create(),
          future: api.discovered
              .get(id, options: [authn.AuthzCache.bearer(context)])
              .then((v) => v.download),
          builder: (BuildContext ctx, AsyncSnapshot<api.Download> snapshot) {
            return ds.Loading(
              loading: !(snapshot.hasData || snapshot.hasError),
              cause: ds.Error.maybeErr(snapshot.error),
              snapshot.data == null ? SizedBox() : DownloadDisplay(snapshot.data!),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themex = ds.Defaults.of(context);
    return SelectionArea(
      child: Container(
        padding: themex.padding,
        child: InkWell(
          onTap: () => onTap(),
          child: Row(
            spacing: themex.spacing!,
            children: [
              Expanded(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    forms.Field(
                      label: Text("ID"),
                      input: Text(
                        current.media.id,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    forms.Field(
                      label: Text("description"),
                      input: Text(
                        current.media.description,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    forms.Field(
                      label: Text("path"),
                      input: Text(
                        current.path,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    forms.Field(
                      label: Text("bytes"),
                      input: typography.Bytes(current.bytes),
                    ),
                    forms.Field(
                      label: Text("paused"),
                      input: ds.Timestamp.iso8601(current.pausedAt),
                    ),
                    forms.Field(
                      label: Text("distributing"),
                      input: forms.Checkbox(value: current.distributing),
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
