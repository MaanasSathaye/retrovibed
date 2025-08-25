import 'package:retrovibed/design.kit/file.drop.well.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/mimex.dart' as mimex;
import 'package:retrovibed/httpx.dart' as httpx;

class AvailableListDisplay extends StatefulWidget {
  final media.FnMediaSearch search;
  final media.FnUploadRequest upload;
  final TextEditingController? controller;
  final FocusNode? focus;
  const AvailableListDisplay({
    super.key,
    this.search = media.media.search,
    this.upload = media.media.upload,
    this.controller,
    this.focus,
  });

  @override
  State<StatefulWidget> createState() => _AvailableListDisplay();
}

class _AvailableListDisplay extends State<AvailableListDisplay> {
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
        .search(req)
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

    return ds.Table(
      loading: _loading,
      cause: _cause,
      leading: ds.SearchTray(
        inputDecoration: InputDecoration(hintText: "search the library"),
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
        leading: Row(
          children: [
            ds.FileDropWell.icon(
              upload,
            ),
          ],
        ),
        autofocus: true,
      ),
      children: _res.items,
      ds.Table.expanded<media.Media>(
        (v) => media.RowDisplay(
          media: v,
          leading: [Icon(mimex.icon(v.mimetype))],
          trailing: [media.ButtonShare(current: v)],
          onTap: media.PlayAction(context, v, _res),
        ),
      ),
      empty: ds.FileDropWell(upload),
    );
  }
}
