import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/uuidx.dart' as uuidx;
import 'package:retrovibed/authn.dart' as authn;
import './metadata.typography.dart' as typography;
import './metadata.icons.dart' as icons;

class MediaEdit extends StatelessWidget {
  final media.Media current;
  final Function(Future<media.Media>) onChange;
  final EdgeInsetsGeometry? padding;
  MediaEdit({
    super.key,
    required this.current,
    required this.onChange,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theming = Theme.of(context);

    return Container(
      padding: padding,
      color: theming.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          forms.Field(
            label: Text("description"),
            input: TextFormField(
              initialValue: current.description,
              onChanged:
                  (v) => onChange(Future.value(current..description = v)),
            ),
          ),
          forms.Field(
            label: Text("mimetype"),
            input: Text(current.mimetype),
          ),
          forms.Field(
            label: Text("sharing"),
            input: typography.sharing(current.torrentId),
          ),
          forms.Field(
            label: Text("archived"),
            input: Row(children: [
              typography.archived(current.archiveId),
              Spacer(),
              ds.LoadingIconButton(
                onPressed: () => media.media.update(
                  current.id,
                  current..archiveId = uuidx.max(),
                  options: [authn.Authenticated.devicebearer(context)],
                ).then((v) => onChange(Future.value(v.media))),
                icon: icons.archived(current.archiveId),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
