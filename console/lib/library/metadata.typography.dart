import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;

Widget archived(String uid, {ds.Defaults? defaults, double size = 24.0}) {
  switch (uid) {
    case "":
    case "00000000-0000-0000-0000-000000000000":
      return Text("disabled");
    case "ffffffff-ffff-ffff-ffff-ffffffffffff":
      return Text("pending");
    default:
      return Text("archived");
  }
}

Widget sharing(String uid, {ds.Defaults? defaults, double  size = 24.0, Color? color}) {
  return toggled(uid, Text("personal"), Text("shared"));
}

Widget toggled(String uid, Widget minmax, Widget o) {
  switch (uid) {
    case "":
    case "00000000-0000-0000-0000-000000000000":
    case "ffffffff-ffff-ffff-ffff-ffffffffffff":
      return minmax;
    default:
      return o;
  }
}