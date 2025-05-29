import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/library/known.table.row.dart';
import 'package:retrovibed/httpx.dart' as httpx;
import './api.dart' as api;

class KnownMediaDropdown extends StatefulWidget {
  final api.FnKnownSearch search;
  final TextEditingController? controller;
  final FocusNode? focus;
  final String current;
  const KnownMediaDropdown({
    super.key,
    this.search = api.known.search,
    this.controller,
    this.focus,
    this.current = "",
  });

  @override
  State<StatefulWidget> createState() => _KnownMediaDropdown();
}

class _KnownMediaDropdown extends State<KnownMediaDropdown> {
  bool _loading = true;
  ds.Error? _cause = null;
  api.KnownSearchResponse _res = api.known.response(
    next: api.known.request(limit: 32),
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

  void refresh(api.KnownSearchRequest req) {
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
  Widget build(BuildContext context) {
    return forms.Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ds.SearchTray(
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
            ),
            ds.Table(
              loading: _loading,
              cause: _cause,
              leading: ds.SearchTray(
                inputDecoration: InputDecoration(
                  hintText: "search the library",
                ),
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
                autofocus: true,
              ),
              children: _res.items,
              flex: 1,
              ds.Table.expanded<api.Known>(
                (v) => KnownRow(
                  current: v,
                  // onTap: media.PlayAction(context, v, _res),
                ),
              ),
              // empty: ds.FileDropWell(upload),
            ),
          ],
        ),
      ),
    );
  }
}
