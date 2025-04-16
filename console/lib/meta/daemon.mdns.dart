import 'package:flutter/material.dart';
import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:console/designkit.dart' as ds;
import 'package:console/httpx.dart' as httpx;
import './api.dart' as api;
import './daemon.manual.dart';

class MDNSDiscovery extends StatefulWidget {
  final void Function(api.Daemon) daemon;

  MDNSDiscovery({super.key, required this.daemon});

  static _MDNSDiscovery? of(BuildContext context) {
    return context.findAncestorStateOfType<_MDNSDiscovery>();
  }

  @override
  State<StatefulWidget> createState() => _MDNSDiscovery();
}

class _MDNSDiscovery extends State<MDNSDiscovery> {
  static const String ServiceName = "_retrovibed._udp.local";
  bool _loading = true;
  Widget? _cause = null;

  void discover() {
    final MDnsClient _client = MDnsClient();
    final Completer<String> _c = new Completer();
    _client
        .start()
        .then((_) {
          _client
              .lookup<PtrResourceRecord>(
                ResourceRecordQuery.serverPointer(ServiceName),
              )
              .listen((ptr) {
                _client
                    .lookup<SrvResourceRecord>(
                      ResourceRecordQuery.service(ptr.domainName),
                    )
                    .listen((srv) {
                      _c.complete("${srv.target}:${srv.port}");
                    }, onError: _c.completeError);
              }, onError: _c.completeError);
        })
        .catchError((cause) {
          _c.completeError(cause);
        });

    _c.future
        .timeout(
          Duration(seconds: 3),
          onTimeout:
              () => Future.error(TimeoutException("operation timed out.")),
        )
        .then((v) {
          setState(() {
            httpx.set(v);
          });
        })
        .catchError((cause) {
          // ignore timeouts they'll be marked as loaded complete and the manual setup will trigger.
        }, test: ds.ErrorTests.timeout)
        .catchError((cause) {
          setState(() {
            _loading = false;
            _cause = ds.Error.unknown(cause);
          });
        })
        .whenComplete(() {
          _client.stop();
          setState(() {
            _loading = false;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    this.discover();
  }

  @override
  Widget build(BuildContext context) {
    return ds.Loading(
      cause: _cause,
      loading: _loading,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 256, maxWidth: 512),
        child: Column(
          children: [
            SelectableText(
              textAlign: TextAlign.center,
              "unable to locate retrovibed on your local network, ensure a retrovibed is running or provide the details to a remote instance.",
            ),
            ManualConfiguration(
              retry: () {
                setState(() {
                  _loading = true;
                  _cause = null;
                });
                this.discover();
              },
              connect: (daemon) {
                setState(() {
                  _cause = null;
                });
                widget.daemon(daemon);
              },
            ),
          ],
        ),
      ),
    );
  }
}
