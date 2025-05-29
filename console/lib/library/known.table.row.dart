import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import './api.dart' as api;

class KnownRow extends StatelessWidget {
  final api.Known current;
  final List<Widget> leading;
  final List<Widget> trailing;
  final void Function()? onTap;
  const KnownRow({
    super.key,
    required this.current,
    this.leading = const [],
    this.trailing = const [],
    this.onTap = ds.defaulttap,
  });

  @override
  Widget build(BuildContext context) {
    final themex = ds.Defaults.of(context);
    List<Widget> children = List.from(leading);
    children += [
      Expanded(child: Text(current.description, overflow: TextOverflow.ellipsis)),
    ];
    children += trailing;

    return Container(
      padding: themex.padding,
      child: InkWell(
        onTap: onTap,
        child: SelectionArea(child: Row(spacing: themex.spacing!, children: children)),
      ),
    );
  }
}