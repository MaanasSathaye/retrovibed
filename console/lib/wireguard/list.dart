import 'package:retrovibed/design.kit/file.drop.well.dart';
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/httpx.dart' as httpx;
import 'package:retrovibed/wireguard/meta.wireguard.pb.dart';
import './api.dart' as api;
import './list.row.dart';
import './icon.checkmark.dart';

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
  State<StatefulWidget> createState() => _ListDisplay();
}

class _ListDisplay extends State<ListDisplay> {
  bool _loading = true;
  ds.Error? _cause = null;
  Wireguard _current = Wireguard();
  api.WireguardSearchResponse _res = api.wireguard.response(
    next: api.wireguard.request(limit: 32),
  );

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

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
          setState(() {
            _loading = false;
          });
        }, test: httpx.ErrorsTest.err404)
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
    api.wireguard
        .current()
        .then(
          (r) => setState(() {
            _current = r.wireguard;
          }),
        )
        .catchError((cause) {}, test: httpx.ErrorsTest.err404)
        .catchError((cause) {
          print("failed to load current vpn settings ${cause}");
        })
        .ignore();
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
        disabled: true,
        onSubmitted: (v) {
          setState(() {
            _res.next.query = v;
            _res.next.offset = ds.SearchTray.Zero;
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
        empty: _res.items.length < _res.next.limit.toInt(),
        trailing: ds.FileDropWell(
          upload,
          child: IgnorePointer(child: Icon(Icons.file_upload_outlined)),
        ),
        autofocus: true,
      ),
      children: _res.items,
      flex: 1,
      ds.Table.expanded<api.Wireguard>(
        (v) {
          final onTap = () {
            return api.wireguard.touch(v.id).then((r) {
              setState(() {
                _current = v;
              });
            });
          };
          return RowDisplay(
            current: v,
            onTap: onTap,
            leading: [IconCheckmark(_current.id == v.id, onTap: onTap)],
          );
        },
      ),
      empty: ds.FileDropWell(upload),
    );
  }
}
