import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import './plan.summary.dart';
import 'package:retrovibed/authn.dart' as authn;
import 'api.dart' as api;

class Purchase extends StatelessWidget {
  final PlanSummary current;
  final PlanSummary desired;
  const Purchase({
    super.key,
    required this.current,
    required this.desired,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: current.key == desired.key ? null : () {
        api.session(this.desired.id, options: [authn.Authenticated.bearer(context)]).then((v) {
          print("DERP DERP ${v}");
          launchUrl(Uri.https("google.com"));
        }).catchError((cause) {
          print("failed ${cause}");
        });
      },
      child: Text("upgrade"),
    );
  }
}
