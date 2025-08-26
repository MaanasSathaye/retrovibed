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
export 'design.kit/buttons.dart';
export 'design.kit/buttons.loading.icon.dart';
export 'design.kit/buttons.loading.widget.dart';
export 'design.kit/typography.dart';
export 'design.kit/bytesx.dart';

abstract class modals {
  static _modals.NodeState? of(BuildContext context) {
    return _modals.of(context);
  }
}

abstract class textediting {
  static void refocus(TextEditingController? controller) {
    if (controller == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    });
  }
}

const Widget? NullWidget = null;

Widget build(Widget Function(BuildContext) b) {
  return Builder(builder: b);
}

Widget layout(Widget Function(BuildContext, BoxConstraints) b) {
  return LayoutBuilder(builder: b);
}
