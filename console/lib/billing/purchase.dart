import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import './plan.summary.dart';

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
        launchUrl(Uri.https("google.com"));
      },
      child: Text("upgrade"),
    );
  }
}
