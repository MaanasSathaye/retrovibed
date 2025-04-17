import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:console/designkit.dart' as ds;
import 'package:console/httpx.dart' as httpx;
import './api.dart' as api;
import './daemon.manual.dart';

class DaemonList extends StatefulWidget {
  final void Function(api.Daemon v)? onTap;
  final void Function(api.Daemon d)? onRemove;
  final Future<api.DaemonSearchResponse> Function(api.DaemonSearchRequest)
  search;

  const DaemonList({
    super.key,
    this.search = api.daemons.search,
    this.onTap,
    this.onRemove,
  });

  @override
  State<StatefulWidget> createState() => _DaemonList();
}

class _DaemonList extends State<DaemonList> {
  bool _loading = true;
  ds.Error? _cause = null;
  Widget? _optional = null;
  api.DaemonSearchResponse _res = api.daemons.response();

  void refresh(api.DaemonSearchRequest req) {
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
  }

  @override
  Widget build(BuildContext context) {
    final current = httpx.host();

    return ds.Table(
      loading: _loading,
      cause: _cause,
      children: _res.items,
      leading: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(hintText: "search servers"),
                  onChanged:
                      (v) => setState(() {
                        _res.next.query = v;
                      }),
                  onSubmitted: (v) {
                    setState(() {
                      _res.next.offset = fixnum.Int64(0);
                    });
                    refresh(_res.next);
                  },
                ),
              ),
              IconButton(
                onPressed:
                    _res.next.offset > 0
                        ? () {
                          setState(() {
                            _res.next.offset -= 1;
                          });
                          refresh(_res.next);
                        }
                        : null,
                icon: Icon(Icons.arrow_left),
              ),
              IconButton(
                onPressed:
                    _res.items.isNotEmpty
                        ? () {
                          setState(() {
                            _res.next.offset += 1;
                          });
                          refresh(_res.next);
                        }
                        : null,
                icon: Icon(Icons.arrow_right),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _optional =
                        _optional != null
                            ? null
                            : ManualConfiguration(
                              connect: (daemon) {
                                setState(() {
                                  _optional = null;
                                  _res.next.offset = fixnum.Int64(0);
                                });
                                refresh(_res.next);
                              },
                            );
                  });
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
          if (_optional != null) _optional!,
        ],
      ),
      ds.Table.inline<api.Daemon>(
        (v) => _RowDisplay(
          hostname: current,
          current: v,
          onTap: widget.onTap == null ? null : () => widget.onTap!(v),
          onRemove: (api.Daemon d) {
            return api.daemons.delete(d.id).then((v) {
              _res.next.offset = _res.next.offset - 1;
              refresh(_res.next);
              return v.daemon;
            });
          },
        ),
      ),
    );
  }
}

class _RowDisplay extends StatelessWidget {
  final String hostname;
  final api.Daemon current;
  final void Function()? onTap;
  final Future<api.Daemon> Function(api.Daemon d)? onRemove;

  const _RowDisplay({
    required this.current,
    required this.hostname,
    this.onTap = ds.defaulttap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final themex = ds.Defaults.of(context);
    return Container(
      child: InkWell(
        onTap: onTap,
        child: Row(
          spacing: themex.spacing!,
          children: [
            Opacity(
              opacity: current.hostname == hostname ? 1.0 : 0.0,
              child: Icon(Icons.check, color: Colors.lightGreenAccent),
            ),
            Expanded(
              child: Text(current.description, overflow: TextOverflow.ellipsis),
            ),
            if (onRemove != null)
              IconButton(
                onPressed: () {
                  onRemove!(current);
                },
                icon: Icon(Icons.remove),
              ),
          ],
        ),
      ),
    );
  }
}
