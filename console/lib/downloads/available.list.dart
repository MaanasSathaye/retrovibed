import 'package:retrovibed/design.kit/file.drop.well.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/mimex.dart' as mimex;

class AvailableListDisplay extends StatefulWidget {
  final media.FnMediaSearch search;
  final media.FnUploadRequest upload;
  final TextEditingController? controller;
  final ValueNotifier<int>? events;
  const AvailableListDisplay({
    super.key,
    this.search = media.discovered.available,
    this.upload = media.discovered.upload,
    this.controller,
    this.events,
  });

  @override
  State<StatefulWidget> createState() => _AvailableListDisplay();
}

class _AvailableListDisplay extends State<AvailableListDisplay> {
  bool _loading = true;
  ds.Error? _cause = null;
  media.MediaSearchResponse _res = media.media.response(
    next: media.media.request(limit: 32),
  );

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void refresh(media.MediaSearchRequest req) {
    widget
        .search(req)
        .then((v) {
          setState(() {
            _res = v;
            _loading = false;
          });
        })
        .catchError((e) {
          setState(() {
            _cause = ds.Error.unknown(e);
            _loading = false;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    refresh(_res.next);
    widget.events?.addListener(() {
      refresh(_res.next);
    });
  }

  @override
  Widget build(BuildContext context) {
    final upload = (FilesEvent v) {
      setState(() {
        _loading = true;
      });

      final multiparts = v.files.map((c) {
        return media.media.uploadable(c.path, c.name, c.mimeType!);
      });

      return Future.microtask(() {
        return Future.wait(
              multiparts.map((fv) {
                return fv.then((v) {
                  return widget
                      .upload((req) {
                        req..files.add(v);
                        return req;
                      })
                      .then((uploaded) {
                        return media.discovered
                            .download(uploaded.media.id)
                            .then((_) {
                              widget.events?.value += 1;
                            });
                      })
                      .catchError((cause) {
                        setState(() {
                          _cause = ds.Error.unknown(cause);
                        });
                      });
                });
              }),
            )
            .then((v) => ds.NullWidget)
            .catchError((cause) {
              return ds.Error.unknown(cause);
            })
            .whenComplete(() {
              setState(() {
                _loading = false;
              });
            });
      });
    };

    return ds.Table(
      loading: _loading,
      cause: _cause,
      children: _res.items,
      leading: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ds.SearchTray(
            inputDecoration: InputDecoration(
              hintText: "search downloadable content",
            ),
            controller: widget.controller,
            onSubmitted: (v) {
              setState(() {
                _res.next.query = v;
                _res.next.offset = fixnum.Int64(0);
              });
              refresh(_res.next);
            },
            next: (i) {
              setState(() {
                _res.next.offset = i;
              });
              refresh(_res.next);
            },
            current: _res.next.offset,
            empty: fixnum.Int64(_res.items.length) < _res.next.limit,
            leading: Row(children: [ds.FileDropWell.icon(upload)]),
            autofocus: true,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [Spacer(), Text("description"), Spacer()],
          ),
        ],
      ),
      ds.Table.expanded<media.Media>(
        (v) => media.RowDisplay(
          media: v,
          onTap:
              () => media.discovered
                  .download(v.id)
                  .then((v) {
                    widget.events ?? refresh(_res.next);
                    widget.events?.value += 1;
                  })
                  .catchError((cause) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to download: $cause")),
                    );
                    return null;
                  }),
          leading: [Icon(mimex.icon(v.mimetype))],
          trailing: [Icon(Icons.download)],
        ),
      ),
    );
  }
}
