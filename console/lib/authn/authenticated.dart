import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/httpx.dart' as httpx;
import 'api.dart' as api;

class Authenticated extends StatefulWidget {
  final Widget child;
  const Authenticated(this.child, {super.key});

  static Future<api.Session> session(BuildContext context) {
    return context.findAncestorStateOfType<_AuthenticatedState>()?.current() ??
        Future.value(api.Session());
  }

  static httpx.Option bearer(BuildContext context) {
    return httpx.Request.bearer(
      session(context).then((s) {
        return s.token;
      }),
    );
  }

  static Future<String> bearerString(BuildContext context) {
    return session(context).then((s) {
      return s.token;
    });
  }

  static httpx.Option devicebearer(BuildContext context) {
    return httpx.Request.bearer(Future.value(httpx.auto_bearer_host()));
  }

  @override
  State<Authenticated> createState() => _AuthenticatedState();
}

class _AuthenticatedState extends State<Authenticated> {
  Widget _cause = const SizedBox();
  DateTime _expires = DateTime.timestamp();
  api.Session _current = api.Session();

  Future<api.Session> current() {
    if (_expires.isAfter(DateTime.timestamp())) {
      return Future.value(_current);
    }

    return api
        .ssh()
        .then<api.Session>((v) {
          switch (v.profiles.length) {
            case 0:
              return api.signup();
            case 1:
              return api.current(v.profiles.first.token);
            default:
              return Future.error(
                new Exception("multiple profiles not currently supported"),
              );
          }
        })
        .then((v) {
          setState(() {
            _expires = DateTime.fromMillisecondsSinceEpoch(
              (Duration(seconds: v.expires.toInt()) - Duration(seconds: 60))
                  .inMilliseconds,
            );
            _current = v;
          });
          return v;
        });
  }

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ds.Overlay(widget.child, overlay: _cause);
  }
}
