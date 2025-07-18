import 'package:retrovibed/design.kit/file.drop.well.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/authn.dart' as authn;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/mimex.dart' as mimex;
import './search.tuning.dart';
import './magnet.links.dart';

class AvailableListDisplay extends StatefulWidget {
  final media.FnDownloadSearch search;
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
  Widget _cause = const SizedBox();
  media.DownloadSearchResponse _res = media.discoveredsearch.response(
    next: media.discoveredsearch.request(limit: 32),
  );

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void resetcause() {
    setState(() {
      _cause = const SizedBox();
    });
  }

  Future<void> refresh(media.DownloadSearchRequest req) {
    return widget
        .search(req, options: [authn.AuthzCache.bearer(context)])
        .then((v) {
          setState(() {
            _res = v;
            _loading = false;
          });
        })
        .catchError((e) {
          setState(() {
            setState(() {
              _cause = ds.Error.unknown(e, onTap: resetcause);
            });
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

      return Future.microtask(() {
        final multiparts = v.files.map((c) {
          return media.media.uploadable(c.path, c.name, c.mimeType!);
        });
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
                      });
                });
              }),
            )
            .then((v) => ds.NullWidget)
            .catchError((cause) {
              return ds.Error.unknown(cause, onTap: resetcause);
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
            autofocus: true,
            inputDecoration: InputDecoration(
              hintText: "search downloadable content",
            ),
            controller: widget.controller,
            onSubmitted: (v) {
              setState(() {
                _res.next.query = v;
                _res.next.offset = fixnum.Int64(0);
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
            empty: fixnum.Int64(_res.items.length) < _res.next.limit,
            leading: Row(
              children: [
                ds.FileDropWell.icon(upload),
                ds.buttons.link(
                  onPressed: () {
                    ds.modals
                        .of(context)
                        ?.push(
                          FractionallySizedBox(
                            widthFactor: 0.75,
                            child: MagnetDownloads(
                              onSubmitted: (derps) {
                                final pending = derps.map((v) => media.discovered.magnet(media.MagnetCreateRequest(uri: v), options: [authn.AuthzCache.bearer(context)]));
                                return Future.wait(pending, eagerError: true).then((_) {
                                  widget.events?.value += 1;
                                  ds.modals.of(context)?.reset();
                              });
                              },
                            ),
                          ),
                        );
                  },
                ),
              ],
            ),
            tuning: LimitedBox(
              maxHeight: 138.0,
              child: SearchTuning(
                _res.next,
                onChange: (media.DownloadSearchRequest n) {
                  setState(() {
                    _res.next = n;
                  });
                },
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [Spacer(), Text("description"), Spacer()],
          ),
        ],
      ),
      ds.Table.expanded<media.Download>(
        (v) => media.RowDisplay(
          media: v.media,
          onTap:
              () => media.discovered
                  .download(v.media.id)
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
          leading: [Icon(mimex.icon(v.media.mimetype))],
          trailing: [Icon(Icons.download)],
        ),
      ),
    );
  }
}
