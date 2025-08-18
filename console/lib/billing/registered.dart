import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/authn.dart' as authn;
import 'api.dart' as api;

class Registered extends StatefulWidget {
  final Widget child;
  final AlignmentGeometry alignment;

  const Registered(this.child, {super.key, this.alignment = Alignment.center});

  static RegisteredState? of(BuildContext context) {
    return context.findAncestorStateOfType<RegisteredState>();
  }

  @override
  State<StatefulWidget> createState() => RegisteredState();
}

class RegisteredState extends State<Registered> {
  bool _loading = true;
  Widget _cause = const SizedBox();
  api.Billing current = api.Billing();

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void _clearCause() {
    setState(() {
      _cause = const SizedBox();
    });
  }

  @override
  void initState() {
    super.initState();

    api
        .lookup(options: [authn.Authenticated.bearer(context)])
        .then((v) {
          if (v.billing.customerId.isEmpty) {
            return api
                .create(options: [authn.Authenticated.bearer(context)])
                .then((v) => v.billing);
          }

          return Future.value(v.billing);
        })
        .then((billing) {
          setState(() {
            current = billing;
          });
        })
        .catchError((cause) {
          setState(() {
            _cause = ds.Error.offline(
              cause,
              onTap: _clearCause,
            );
          });
        }, test: ds.ErrorTests.offline)
        .catchError((cause) {
          setState(() {
            _cause = ds.Error.connectivity(
              cause,
              onTap: _clearCause,
            );
          });
        }, test: ds.ErrorTests.connectivity)
        .catchError((cause) {
          setState(() {
            _cause = ds.Error.unknown(
              cause,
              onTap: _clearCause,
            );
          });
        })
        .whenComplete(() {
          setState(() {
            _loading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return ds.Loading(key: ValueKey(current.customerId), loading: _loading, cause: _cause, widget.child);
  }
}
