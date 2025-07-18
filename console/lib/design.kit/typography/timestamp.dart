import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Timestamp extends StatelessWidget {
  final DateTime timestamp;
  final String Function(DateTime)? format;
  const Timestamp(this.timestamp, {super.key, this.format});

  factory Timestamp.iso8601(String ts) {
    return Timestamp(DateTime.parse(ts));
  }

  @override
  Widget build(BuildContext context) {
    return Text((this.format ?? DateFormat("y MMMM EEEE d hh:mm a").format)(timestamp.toLocal()));
  }
}
