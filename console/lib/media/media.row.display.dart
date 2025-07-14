import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import './media.pb.dart';

class RowDisplay extends StatelessWidget {
  final Media media;
  final List<Widget> leading;
  final List<Widget> trailing;
  final Future<void> Function() onTap;
  const RowDisplay({
    super.key,
    required this.media,
    this.leading = const [],
    this.trailing = const [],
    onTap,
  }): onTap = onTap ?? ds.defaulttapv;

  @override
  Widget build(BuildContext context) {
    final themex = ds.Defaults.of(context);

    return SelectionArea(child: Container(
      padding: themex.padding,
      child: InkWell(
        onTap: () => onTap(),
        child: Row(spacing: themex.spacing!, children: [
          ...leading,
          Expanded(child: Text(media.description, overflow: TextOverflow.ellipsis)),
          ...trailing
        ]),
      ),
    ));
  }
}
