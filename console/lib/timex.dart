final DateTime inf =
    DateTime.fromMillisecondsSinceEpoch(253402300799999, isUtc: true).toUtc();
final DateTime epoch =
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toUtc();
final DateTime neginf =
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toUtc(); // todo.

DateTime iso8601(String ts, {DateTime? empty}) {
  return ts.isEmpty ? empty ?? epoch : DateTime.parse(ts).toUtc();
}
