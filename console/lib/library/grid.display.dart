import 'package:retrovibed/design.kit/file.drop.well.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/library/known.media.display.dart';
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/authn.dart' as authn;
import 'package:retrovibed/httpx.dart' as httpx;
import './api.dart' as api;
import './search.tuning.dart';
import './media.settings.dart';

class AvailableGridDisplay extends StatefulWidget {
  final media.FnMediaSearch search;
  final media.FnUploadRequest upload;
  final TextEditingController? controller;
  final FocusNode? focus;
  const AvailableGridDisplay({
    super.key,
    this.search = media.media.get,
    this.upload = media.media.upload,
    this.controller,
    this.focus,
  });

  @override
  State<StatefulWidget> createState() => _AvailableGridDisplay();
}

class _AvailableGridDisplay extends State<AvailableGridDisplay> {
  bool _loading = true;
  Widget _cause = const SizedBox();
  media.MediaSearchResponse _res = media.media.response(
    next: media.media.request(limit: 32),
  );

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void reseterr() {
    setState(() {
      _cause = const SizedBox();
    });
  }

  Future<void> refresh(media.MediaSearchRequest req) {
    return widget
        .search(req, options: [authn.AuthzCache.bearer(context)])
        .then((v) {
          setState(() {
            _res = v;
            _loading = false;
          });

          widget.focus?.requestFocus();
          ds.textediting.refocus(widget.controller);
        })
        .catchError((cause) {
          setState(() {
            _cause = ds.Error.unauthorized(cause, onTap: reseterr);
            _loading = false;
          });
        }, test: httpx.ErrorsTest.unauthorized)
        .catchError((e) {
          setState(() {
            _cause = ds.Error.unknown(e, onTap: reseterr);
            _loading = false;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    _res.next..query = widget.controller?.text ?? "";
    refresh(_res.next);
  }

  @override
  Widget build(BuildContext context) {
    final defaults = ds.Defaults.of(context);
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
                        setState(() {
                          _res.items.add(uploaded.media);
                        });
                      })
                      .catchError((cause) {
                        setState(() {
                          _cause = ds.Error.unknown(cause, onTap: reseterr);
                        });
                      });
                });
              }),
            )
            .then((v) => ds.NullWidget)
            .catchError((cause) {
              return ds.Error.unknown(cause, onTap: reseterr);
            })
            .whenComplete(
              () => setState(() {
                _loading = false;
              }),
            );
      });
    };

    return ds.Loading(
      cause: _cause,
      loading: _loading,
      Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ds.SearchTray(
              inputDecoration: InputDecoration(hintText: "search library"),
              controller: widget.controller,
              focus: widget.focus,
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
              leading: Row(children: [ds.FileDropWell.icon(upload)]),
              autofocus: true,
              tuning: LimitedBox(
                maxHeight: 128.0,
                child: SearchTuning(
                  _res.next,
                  onChange: (media.MediaSearchRequest n) {
                    setState(() {
                      _res.next = n;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: defaults.padding,
                itemCount: _res.items.length, // Number of items in your grid
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 633, // Maximum width of each item
                  crossAxisSpacing:
                      (defaults.spacing ?? 0.0) / 2, // Spacing between columns
                  mainAxisSpacing:
                      (defaults.spacing ?? 0.0) / 2, // Spacing between rows
                  childAspectRatio:
                      16 / 9, // Aspect ratio of each grid item (width/height)
                ),
                itemBuilder: (context, index) {
                  var _media = _res.items.elementAt(index);
                  var onSettings = () {
                    ds.modals
                        .of(context)
                        ?.push(
                          MediaSettings(
                            current: _media,
                            onChange: (pending) {
                              pending
                                  .then((v) {
                                    final replaced = _res.items.map(
                                      (o) => o.id == v.id ? v : o,
                                    );

                                    setState(() {
                                      _res = media.MediaSearchResponse(
                                        items: replaced,
                                        next: _res.next,
                                      );
                                    });

                                    ds.modals.of(context)?.push(null);
                                  })
                                  .catchError((cause) {
                                    setState(() {
                                      _cause = ds.Error.unknown(cause);
                                    });
                                  });
                            },
                          ),
                        );
                  };

                  switch (_media.knownMediaId) {
                    case "":
                    case "00000000-0000-0000-0000-000000000000":
                    case "ffffffff-ffff-ffff-ffff-ffffffffffff":
                      return KnownMediaDisplay.missing(
                        _media,
                        onDoubleTap: media.PlayAction(context, _media, _res),
                        onSettings: onSettings,
                      );
                    default:
                      return KnownMediaDisplay(
                        api.known
                            .get(_media.knownMediaId, options: [authn.Authenticated.devicebearer(context)])
                            .then(
                              (w) =>
                                  (w.known..description = _media.description),
                            ),
                        key: ValueKey(_media.id),
                        onDoubleTap: media.PlayAction(context, _media, _res),
                        onSettings: onSettings,
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
