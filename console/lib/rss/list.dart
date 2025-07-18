import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'feed.edit.dart';
import 'feed.row.dart';
import './api.dart' as api;

void _Noop(api.Feed up) {}

class Item extends StatelessWidget {
  final api.Feed current;
  final void Function(api.Feed upd) onChange;
  const Item({
    super.key,
    required api.Feed this.current,
    this.onChange = _Noop,
  });

  @override
  Widget build(BuildContext context) {
    return ds.Accordion(
      description: FeedRow(current: this.current),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           forms.Field(
            label: Text("id"),
            input: Text(current.id),
          ),
          forms.Field(
            label: Text("next check"),
            input: ds.DurationWidget.untilISO8601(current.nextCheck),
          ),
          Edit(
            current: this.current,
            onChange: (u) {
              api.create(api.FeedCreateRequest(feed: u)).then((resp) {
                onChange(resp.feed);
              });
            },
          ),
        ],
      ),
    );
  }
}

class ListFeeds extends StatelessWidget {
  final List<api.Feed> current;
  const ListFeeds({super.key, required List<api.Feed> this.current});

  @override
  Widget build(BuildContext context) {
    if (this.current.isEmpty) {
      return Container();
    }
    return Container(
      child: Column(
        spacing: 5.0,
        children: this.current.map((f) => Item(current: f)).toList(),
      ),
    );
  }
}
