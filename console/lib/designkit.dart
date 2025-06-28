import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/modals.dart' as _modals;

export 'design.kit/screens.dart';
export 'design.kit/accordian.dart';
export 'design.kit/errors.dart';
export 'design.kit/theme.defaults.dart';
export 'design.kit/refresh.dart';
export 'design.kit/periodic.dart';
export 'design.kit/tables.dart';
export 'design.kit/debug.dart';
export 'design.kit/file.drop.well.dart';
export 'design.kit/inputs.dart';
export 'design.kit/search.tray.dart';
export 'design.kit/card.dart';
export 'design.kit/rating.dart';

abstract class modals {
  static _modals.NodeState? of(BuildContext context) {
    return _modals.of(context);
  }
}

abstract class buttons {
  static IconButton refresh({required void Function()? onPressed}) {
    return IconButton(onPressed: onPressed, icon: Icon(Icons.refresh));
  }
}
const Widget? NullWidget = null;
