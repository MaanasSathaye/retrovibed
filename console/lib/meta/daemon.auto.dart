import 'dart:io';
import 'package:flutter/material.dart';
import 'package:console/designkit.dart' as ds;
import 'package:console/httpx.dart' as httpx;
import './api.dart' as api;
import './daemon.mdns.dart' as mdns;

class DaemonHttpOverrides extends HttpOverrides {
  final List<String> ips;
  DaemonHttpOverrides({this.ips = const []}) {}
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return ips.any((v) => host == v) ||
            host == "localhost" ||
            host == Platform.localHostname;
      };
  }
}

class EndpointAuto extends StatefulWidget {
  final Widget child;
  final List<String> defaultips;
  final void Function(api.Daemon v)? onTap;
  final Future<api.DaemonLookupResponse> Function() latest;

  const EndpointAuto(
    this.child, {
    super.key,
    this.latest = api.daemons.latest,
    this.onTap,
    this.defaultips = const [],
  });

  static _DaemonAuto? of(BuildContext context) {
    return context.findAncestorStateOfType<_DaemonAuto>();
  }

  @override
  State<StatefulWidget> createState() => _DaemonAuto();
}

class _DaemonAuto extends State<EndpointAuto> {
  bool _loading = true;
  ds.Error? _cause = null;
  api.Daemon? _res;

  void setdaemon(api.Daemon? d) {
    if (d == null) return;
    refresh(Future.value(d));
  }

  void refresh(Future<api.Daemon> pending) {
    setState(() {
      _loading = true;
    });

    pending
        .then((v) {
          return api.healthz(host: v.hostname).then((value) => v);
        })
        .then((v) {
          setState(() {
            httpx.set(v.hostname);
            HttpOverrides.global = DaemonHttpOverrides(
              ips: [v.hostname.split(":").first],
            );

            _res = v;
            _loading = false;
          });
        })
        .catchError((e) {
          setState(() {
            _loading = false;
          });
        }, test: httpx.ErrorsTest.err404)
        .catchError((e) {
          setState(() {
            _loading = false;
          });
        }, test: ds.ErrorTests.offline)
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
    HttpOverrides.global = DaemonHttpOverrides(ips: widget.defaultips);
    refresh(this.widget.latest().then((r) => r.daemon));
  }

  @override
  Widget build(BuildContext context) {
    return ds.Loading(
      child:
          _res == null
              ? mdns.MDNSDiscovery(
                daemon: (d) {
                  setState(() {
                    _res = d;
                  });
                },
              )
              : widget.child,
      cause: _cause,
      loading: _loading,
    );
  }
}
