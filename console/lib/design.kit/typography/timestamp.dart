import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Timestamp extends StatelessWidget {
  static final DateTime inf = DateTime.fromMillisecondsSinceEpoch(253402300799999, isUtc: true).toUtc();
  static final DateTime neginf = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toUtc(); // todo.
  final DateTime timestamp;
  final String Function(DateTime)? format;
  final Widget _inf = const Text("never");
  final Widget _neginf = const Text("always");

  const Timestamp(this.timestamp, {super.key, this.format});

  factory Timestamp.iso8601(String ts) {
    return Timestamp(ts.isEmpty ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true) : DateTime.parse(ts).toUtc());
  }

  @override
  Widget build(BuildContext context) {
    if (inf.difference(timestamp).inMilliseconds == 0) {
      return _inf;
    }

    if (neginf.difference(timestamp).inMilliseconds == 0) {
      return _neginf;
    }

    return Text((this.format ?? DateFormat("y MMMM EEEE d hh:mm a").format)(timestamp.toLocal()));
  }
}

