import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/httpx.dart' as httpx;
import 'known.media.card.dart';
import './api.dart' as api;

class KnownMediaDropdown extends StatefulWidget {
  final api.FnKnownSearch search;
  final TextEditingController? controller;
  final FocusNode? focus;
  final String current;
  final void Function(api.Known k)? onChange;
  const KnownMediaDropdown({
    super.key,
    this.search = api.known.search,
    this.controller,
    this.focus,
    this.current = "",
    this.onChange,
  });

  @override
  State<StatefulWidget> createState() => _KnownMediaDropdown();
}

class _KnownMediaDropdown extends State<KnownMediaDropdown> {
  bool _loading = true;
  Widget _cause = const SizedBox();
  api.KnownSearchResponse _res = api.known.response(
    next: api.known.request(limit: 32),
  );
  api.Known? current = null;

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void reseterr() {
    setState(() {
      _cause = const SizedBox();
    });
  }

  Future<void> refresh(api.KnownSearchRequest req) {
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
    refresh(_res.next);
  }

  @override
  Widget build(BuildContext context) {
    final defaults = ds.Defaults.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ds.SearchTray(
          inputDecoration: InputDecoration(hintText: "search known media"),
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
          autofocus: true,
        ),
        ds.Loading(
          loading: _loading,
          cause: _cause,
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: defaults.padding,
            itemCount: _res.items.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 512, // Maximum width of each item
              crossAxisSpacing:
                  (defaults.spacing) / 2, // Spacing between columns
              mainAxisSpacing:
                  (defaults.spacing) / 2, // Spacing between rows
              childAspectRatio: 2 / 3,
            ),
            itemBuilder: (context, index) {
              var v = _res.items.elementAt(index);
              return KnownMediaCard(
                v,
                onDoubleTap:
                    widget.onChange == null ? null : () => widget.onChange!(v),
              );
            },
          ),
        ),
      ],
    );
  }
}
