import 'package:retrovibed/design.kit/file.drop.well.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/httpx.dart' as httpx;
import './api.dart' as api;
import './list.row.dart';

class ListDisplay extends StatefulWidget {
  final api.FnWireguardSearch search;
  final api.FnUploadRequest upload;
  final TextEditingController? controller;
  final FocusNode? focus;
  const ListDisplay({
    super.key,
    this.search = api.wireguard.get,
    this.upload = api.wireguard.upload,
    this.controller,
    this.focus,
  });

  @override
  State<StatefulWidget> createState() => _AvailableListDisplay();
}

class _AvailableListDisplay extends State<ListDisplay> {
  bool _loading = true;
  ds.Error? _cause = null;
  api.WireguardSearchResponse _res = api.wireguard.response(
    next: api.wireguard.request(limit: 32),
  );

  void reseterr() {
    setState(() {
      _cause = null;
    });
  }

  void refresh(api.WireguardSearchRequest req) {
    widget
        .search(req)
        .then((v) {
          setState(() {
            _res = v;
            _loading = false;
          });

          widget.focus?.requestFocus();
          ds.SearchTray.refocus(widget.controller);
        })
        .catchError((cause) {
          print("DERP 0");
          if(!super.mounted) return;
          setState(() {
            _cause = ds.Error.unauthorized(cause, onTap: reseterr);
            _loading = false;
          });
        }, test: httpx.ErrorsTest.unauthorized)
        .catchError((e) {
          print("DERP 1");
          if(!super.mounted) return;
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
        return api.wireguard.uploadable(c.path, c.name, c.mimeType!);
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
                          _res.items.add(uploaded.wireguard);
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
          controller: widget.controller,
          focus: widget.focus,
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
          trailing: ds.FileDropWell(
            upload,
            child: IgnorePointer(child: Icon(Icons.file_upload_outlined)),
          ),
          autofocus: true,
        ),
        children: _res.items,
        flex: 1,
        ds.Table.expanded<api.Wireguard>(
          (v) => RowDisplay(
            current: v,
          ),
        ),
        empty: ds.FileDropWell(upload),
    );
  }
}
