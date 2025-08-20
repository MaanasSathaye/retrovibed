import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;

Widget archived(String uid, {ds.Defaults? defaults, double size = 24.0}) {
  switch (uid) {
    case "":
    case "00000000-0000-0000-0000-000000000000":
      return SizedBox.square(dimension: size);
    case "ffffffff-ffff-ffff-ffff-ffffffffffff":
      return Icon(Icons.pending_actions_outlined, size: size, color: defaults?.opaque);
    default:
      return Icon(Icons.archive_outlined, size: size);
  }
}

Widget sharing(String uid, {ds.Defaults? defaults, double  size = 24.0, Color? color}) {
  switch (uid) {
    case "":
    case "00000000-0000-0000-0000-000000000000":
    case "ffffffff-ffff-ffff-ffff-ffffffffffff":
      return Icon(Icons.share_outlined, size: size, color: defaults?.opaque);
    default:
      return Icon(Icons.share, size: size, color: defaults?.success);
  }
}