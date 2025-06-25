import 'dart:io';
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/httpx.dart' as httpx;
import 'package:retrovibed/retrovibed.dart' as retro;
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
  Widget Function(void Function(api.Daemon) connect, {void Function()? retry})
  _preamble =
      (connect, {retry}) => mdns.NoLocalService(connect: connect, retry: retry);

  Future<void> setdaemon(api.Daemon? d) {
    if (d == null) return Future.value(null);
    return refresh(Future.value(d));
  }

  Future<void> refresh(Future<api.Daemon> pending) {
    setState(() {
      _loading = true;
    });

    final reseterr = () {
      setState(() {
        _cause = null;
      });
    };

    return pending
        .then((v) {
          return api.daemons.connectable(v);
        })
        .then((v) {
          final ips = [...widget.defaultips, v.hostname.split(":").first];
          HttpOverrides.global = DaemonHttpOverrides(ips: ips);
          setState(() {
            httpx.set(v.hostname);
            _res = v;
          });
        })
        .catchError((e) {
          // no service known
          setState(() {
            _preamble =
                (connect, {retry}) => mdns.InitialSetup(
                  connect: (d) => refresh(Future.value(d)),
                  retry: retry,
                );
          });
        }, test: httpx.ErrorsTest.err404)
        .catchError((e) {
          setState(() {
            _cause = ds.Error.unauthorized(
              e,
              onTap: reseterr,
              color: Color.fromRGBO(0, 0, 0, 0.80),
              message: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    "you've attempted to access a system you havent been granted access to yet.",
                  ),
                  SelectableText(
                    "provide the system's administrator with the following to be granted access:",
                  ),
                  SelectableText(retro.public_key()),
                ],
              ),
            );
          });
        }, test: httpx.ErrorsTest.unauthorized)
        .catchError((e) {
          setState(() {
            _cause = ds.Error.unauthorized(
              e,
              onTap: reseterr,
              message: SelectableText(
                "you've attempted to access a service you havent been granted access to yet.",
              ),
            );
          });
        }, test: httpx.ErrorsTest.forbidden)
        .catchError((e) {
          // fallback to manual setup.
        }, test: ds.ErrorTests.offline)
        .catchError((e) {
          // fallback to manual setup.
        }, test: ds.ErrorTests.dnsresolution)
        .catchError((e) {
          setState(() {
            _cause = ds.Error.unknown(e, onTap: reseterr);
          });
        })
        .whenComplete(() {
          setState(() {
            _loading = false;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    HttpOverrides.global = DaemonHttpOverrides(ips: widget.defaultips);
    refresh(
      widget.latest().then((r) => r.daemon).catchError((e) {
        // no service known
        return api.daemons
            .create(
              api.DaemonCreateRequest(
                daemon: api.Daemon(hostname: httpx.localhost()),
              ),
            )
            .then((v) => v.daemon);
      }, test: httpx.ErrorsTest.err404),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ds.Overlay(
      child: ds.Loading(
        loading: _loading,
        child:
            _res == null
                ? mdns.MDNSDiscovery(
                  daemon: (d) {
                    setState(() {
                      _res = d;
                    });
                  },
                  preamble: _preamble,
                )
                : widget.child,
      ),
      overlay: _cause,
    );
  }
}
