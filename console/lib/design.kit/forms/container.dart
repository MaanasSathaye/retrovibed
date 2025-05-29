import 'package:flutter/material.dart' as m;
import 'package:retrovibed/design.kit/theme.defaults.dart' as theming;


class Container extends m.Container {
  final m.Widget child;

  Container({super.key, super.decoration, required this.child});

  @override
  m.Widget build(m.BuildContext context) {
    final theme = m.Theme.of(context);
    return m.Container(
      padding: theme.extension<theming.Defaults>()!.padding,
      decoration: m.BoxDecoration(color: theme.scaffoldBackgroundColor),
      child: m.SelectionArea(child: child),
    );
  }
}
