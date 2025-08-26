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
      spacing: themex.spacing,
      children: [
        if (current.hasDescription()) Expanded(
            child: Text(
              current.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (current.hasDescription()) Spacer(),
        Expanded(
          child: Text(
            current.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Spacer(),
        current.autodownload ? Icon(Icons.downloading_rounded) : SizedBox(width: 24.0, height: 24.0),
        current.autoarchive ? Icon(Icons.archive_outlined) : SizedBox(width: 24.0, height: 24.0),
        current.contributing ? Icon(Icons.handshake_outlined) :  SizedBox(width: 24.0, height: 24.0),
      ],
    );
  }
}
