import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart';
import './list.dart';
import './feed.new.dart';
import './api.dart' as api;

class ListSearchable extends StatefulWidget {
  final api.FnSearch search;

  ListSearchable({super.key, this.search = api.search});

  @override
  State<ListSearchable> createState() => SearchableView();
}

class SearchableView extends State<ListSearchable> {
  static const zerooverlay = const SizedBox();
  bool _loading = true;
  Widget _cause = const SizedBox();
  Widget _overlay = zerooverlay;
  api.Feed _created = api.Feed();
  api.FeedSearchResponse _res = api.FeedSearchResponse(
    next: api.FeedSearchRequest(query: '', offset: Int64(0), limit: Int64(10)),
    items: [],
  );

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  Future<api.FeedSearchResponse> refresh(api.FeedSearchRequest next) {
    return widget
        .search(next)
        .then((r) {
          setState(() {
            _res = r;
          });
          return r;
        })
        .whenComplete(() {
          setState(() {
            _loading = false;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    refresh(_res.next).catchError((e) {
      setState(() {
        _cause = ds.Error.unknown(e);
      });
      return _res;
    });
  }

  void resetleading() => setState(() {
    _overlay = const SizedBox();
    _loading = false;
    _created = api.Feed();
  });

  void updatefeed(api.Feed upd) => setState(() {
    _created = upd;
    _overlay = _FeedCreate(
      current: upd,
      onCancel: resetleading,
      onSubmit: submitfeed,
      onChange: updatefeed,
    );
  });

  void submitfeed(api.Feed n) {
    setState(() => _loading = true);
    api
        .create(api.FeedCreateRequest(feed: n))
        .then((v) {
          refresh(_res.next);
          return v;
        })
        .then((v) => resetleading())
        .catchError((e) {
          setState(() {
            _cause = ds.Error.unknown(e);
            _loading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final feedproto = _FeedCreate(
      current: _created,
      onCancel: resetleading,
      onSubmit: submitfeed,
      onChange: updatefeed,
    );

    return ds.Table(
      loading: _loading,
      cause: _cause,
      leading: ds.SearchTray(
        inputDecoration: InputDecoration(hintText: "search feeds"),
        onSubmitted: (v) {
          setState(() {
            _res.next.query = v;
            _res.next.offset = Int64(0);
          });
          return refresh(_res.next);
        },
        next: (i) {
          setState(() {
            _res.next.offset = i;
          });
          refresh(_res.next);
        },
        current: _res.next.offset,
        empty: Int64(_res.items.length) < _res.next.limit,
        leading: Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _overlay = _overlay == zerooverlay ? feedproto : zerooverlay;
                });
              },
              icon: Icon(_overlay == zerooverlay ? Icons.add : Icons.remove),
            ),
          ],
        ),
        autofocus: true,
      ),
      children: _res.items,
      (items) => Column(
        mainAxisSize: MainAxisSize.min,
        children:
            items
                .map(
                  (w) => Item(
                    current: w,
                    onChange: (v) {
                      final upd =
                          _res.items
                              .map((old) => old.id == v.id ? v : old)
                              .toList();
                      setState(() {
                        _res = api.FeedSearchResponse(
                          next: _res.next.deepCopy(),
                          items: upd,
                        );
                      });
                    },
                  ),
                )
                .toList(),
      ),
      empty: feedproto,
      overlay: _overlay,
    );
  }
}

class _FeedCreate extends StatelessWidget {
  final api.Feed current;
  final Function(api.Feed)? onChange;
  final Function(api.Feed)? onSubmit;
  final Function()? onCancel;

  _FeedCreate({
    required this.current,
    this.onChange,
    this.onCancel,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theming = Theme.of(context);
    final themex = ds.Defaults.of(context);
    return Card(
      color: theming.scaffoldBackgroundColor,
      child: Column(
        spacing: themex.spacing,
        mainAxisSize: MainAxisSize.min,
        children: [
          FeedNew(current: current, onChange: onChange),
          Row(
            spacing: themex.spacing,
            children: [
              Spacer(),
              TextButton(onPressed: onCancel, child: Text("cancel")),
              TextButton(
                onPressed: () {
                  onSubmit?.call(current);
                },
                child: Text("create"),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
