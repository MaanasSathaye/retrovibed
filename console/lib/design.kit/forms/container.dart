import 'package:flutter/material.dart' as m;
import 'package:retrovibed/design.kit/theme.defaults.dart' as theming;

class Container extends m.Container {
  final m.Widget child;
  final m.EdgeInsets? padding;
  final m.BoxDecoration? decoration;

  Container(this.child, {super.key, this.decoration, this.padding});

  @override
  m.Widget build(m.BuildContext context) {
    final theme = m.Theme.of(context);

    return m.Container(
      margin: theme.extension<theming.Defaults>()!.margin,
      padding: theme.extension<theming.Defaults>()!.padding,
      decoration:
          decoration ??
          m.BoxDecoration(
            color: theme.cardColor,
            borderRadius: m.BorderRadius.circular(10.0),
          ),
      child: m.SelectionArea(child: child),
    );
  }
}
