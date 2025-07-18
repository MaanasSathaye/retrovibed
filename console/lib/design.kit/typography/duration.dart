import 'package:flutter/material.dart';

class DurationWidget extends StatelessWidget {
  final Duration duration;

  const DurationWidget(this.duration, {super.key});

  factory DurationWidget.until(DateTime timestamp) {
    return DurationWidget(DateTime.now().difference(timestamp));
  }

  factory DurationWidget.untilISO8601(String isoTimestamp) {
    return DurationWidget.until(DateTime.parse(isoTimestamp));
  }

  @override
  Widget build(BuildContext context) {
    String sign = '';
    Duration positiveDuration = duration;

    if (duration.isNegative) {
      sign = '-';
      positiveDuration = duration.abs();
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigits(
      positiveDuration.inMinutes.remainder(60),
    );
    final String twoDigitSeconds = twoDigits(
      positiveDuration.inSeconds.remainder(60),
    );

    final String formattedDuration =
        '$sign${twoDigits(positiveDuration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';

    return Text(formattedDuration);
  }
}
