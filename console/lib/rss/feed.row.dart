import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import './rss.pb.dart';

class FeedRow extends StatelessWidget {
  final Feed current;
  final Function(Feed)? onChange;
  FeedRow({super.key, Feed? current, this.onChange})
    : current = current ?? (Feed.create()..autodownload = false);

  @override
  Widget build(BuildContext context) {
    final themex = ds.Defaults.of(context);

    return Row(
      spacing: themex.spacing ?? 0.0,
      children: [
        if (current.hasDescription())
          Expanded(
            child: Text(
              current.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Expanded(
          child: Text(
            current.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (current.autodownload) Icon(Icons.downloading_rounded),
        if (current.autoarchive) Icon(Icons.archive_outlined),
        if (current.contributing) Icon(Icons.handshake_outlined),
      ],
    );
  }
}
