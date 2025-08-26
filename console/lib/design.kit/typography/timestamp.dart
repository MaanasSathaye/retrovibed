import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retrovibed/timex.dart' as timex;

class Timestamp extends StatelessWidget {
  final DateTime timestamp;
  final String Function(DateTime)? format;
  final Widget _inf = const Text("never");
  final Widget _neginf = const Text("always");

  const Timestamp(this.timestamp, {super.key, this.format});

  factory Timestamp.iso8601(String ts, {DateTime? empty }) {
    return Timestamp(timex.iso8601(ts, empty: empty));
  }

  @override
  Widget build(BuildContext context) {
    if (timex.inf.difference(timestamp).inMilliseconds == 0) {
      return _inf;
    }

    if (timex.neginf.difference(timestamp).inMilliseconds == 0) {
      return _neginf;
    }

    return Text((this.format ?? DateFormat("y MMMM EEEE d hh:mm a").format)(timestamp.toLocal()));
  }
}

