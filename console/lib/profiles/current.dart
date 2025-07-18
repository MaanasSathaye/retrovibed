import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/authn.dart' as authn;
import 'package:retrovibed/httpx.dart' as httpx;
import 'package:url_launcher/url_launcher.dart';

class Current extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CurrentState();
  }
}

class _CurrentState extends State<Current> {
  bool _loading = true;
  Widget _cause = const SizedBox();
  authn.Session current = authn.Session();

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void refresh() {
    setState(() {
      _loading = true;
      _cause = const SizedBox();
    });

    authn.Authenticated.session(context)
        .then((session) {
          setState(() {
            _loading = false;
            current = session;
          });
        })
        .catchError((cause) {
          setState(() {
            _cause = ds.Error.offline(cause, onTap: refresh);
          });
        }, test: ds.ErrorTests.offline)
        .catchError((cause) {
          setState(() {
            _cause = ds.Error.connectivity(cause, onTap: refresh);
          });
        }, test: ds.ErrorTests.connectivity)
        .catchError((cause) {
          setState(() {
            _cause = ds.Error.unknown(cause, onTap: refresh);
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
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return forms.Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      ds.Loading(
        cause: _cause,
        loading: _loading,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            forms.Field(label: Text("id"), input: Text(current.account.id)),
            forms.Field(
              label: Text("name"),
              input: Text(current.account.description),
            ),
            TextButton(
              child: Text("open web console"),
              onPressed: () {
                authn
                    .otp(authn.Authenticated.bearerString(context))
                    .then((r) {
                      final Uri q = Uri.https(httpx.consoleendpoint(), "/", {
                        "lt": r.token,
                      });
                      launchUrl(q);
                    })
                    .catchError((cause) {
                      setState(() {
                        _cause = ds.Error.unknown(cause, onTap: refresh);
                      });
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
