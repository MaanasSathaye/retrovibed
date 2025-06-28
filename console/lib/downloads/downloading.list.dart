import 'dart:async';
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/media.dart' as media;

class DownloadingListDisplay extends StatefulWidget {
  final media.FnDownloadSearch search;
  final ValueNotifier<int>? events;
  const DownloadingListDisplay({
    super.key,
    this.search = media.discovered.downloading,
    this.events,
  });

  @override
  State<StatefulWidget> createState() => _DownloadingListState();
}

class _DownloadingListState extends State<DownloadingListDisplay> {
  Future<List<Widget>> _pending = Future.value([]);
  List<Widget> items = [];
  Timer? period;

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void refresh() {
    _pending = widget
        .search(media.discoveredsearch.request(limit: 3))
        .then(
          (v) =>
              v.items
                  .map(
                    (v) =>
                        ds.ErrorBoundary(media.RefreshingDownload(current: v))
                            as Widget,
                  )
                  .toList(),
        )
        .then((v) {
          setState(() {
            items = v;
          });
          return v;
        })
        .catchError(
          ds.Error.boundary(
            context,
            List<media.RefreshingDownload>.empty(),
            ds.Error.offline,
          ),
          test: ds.ErrorTests.offline,
        )
        .catchError((e) => throw ds.Error.unknown(e));
  }

  @override
  void initState() {
    super.initState();
    refresh();
    period = Timer.periodic(
      const Duration(seconds: 20),
      (p) => setState(this.refresh),
    );
    widget.events?.addListener(() {
      refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    period?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: <Widget>[],
      future: _pending,
      builder: (BuildContext ctx, AsyncSnapshot<List<Widget>> snapshot) {
        return ds.Loading(
          cause: ds.Error.maybeErr(snapshot.error),
          ds.RefreshBoundary(
            onReset: () {
              widget.events ?? setState(this.refresh);
              widget.events?.value += 1;
            },
            ListView(shrinkWrap: true, children: items),
          ),
        );
      },
    );
  }
}
