import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import './meta.wireguard.pb.dart';

class RowDisplay extends StatelessWidget {
  final Wireguard current;
  final List<Widget> leading;
  final List<Widget> trailing;
  final Future<void> Function()? onTap;
  const RowDisplay({
    super.key,
    required this.current,
    this.leading = const [],
    this.trailing = const [],
    this.onTap = ds.defaulttapv,
  });

  @override
  Widget build(BuildContext context) {
    final themex = ds.Defaults.of(context);
    List<Widget> children = List.from(leading);
    children += [
      Expanded(child: Text(current.id, overflow: TextOverflow.ellipsis)),
    ];
    children += trailing;

    return Container(
      padding: themex.padding,
      child: InkWell(
        onTap: onTap,
        child: Row(spacing: themex.spacing!, children: children),
      ),
    );
  }
}